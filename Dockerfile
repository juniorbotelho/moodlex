# syntax=docker.io/docker/dockerfile:1.2
ARG ALPINE_VERSION=3.17
FROM docker.io/alpine:${ALPINE_VERSION} as Moodle
WORKDIR "/var/www"

# Customize the environment during both execution and build time by modifying the environment variables added to the container's shell
# When building your image, make sure to set the 'TZ' environment variable to your desired time zone location, for example 'America/Sao_Paulo'
# See more: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
ARG TZ="America/Sao_Paulo"
ARG HTTP_PROXY=""
ARG PHP_SOCKET_PATH="/etc/php8/php-fpm.d/www.conf"
ARG GITHUB_RAW="https://raw.githubusercontent.com/juniorbotelho/moodle/main"

ENV SCRIPT_PATH="/etc/scripts"
ENV HTTP_PROXY=""
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_POST_MAX_SIZE=16M
ENV PHP_UPLOAD_MAX_FILESIZE=1024M

# Download custom scripts that will be run after build or when run a new container of this image
ADD ${GITHUB_RAW}/scripts/admin_installation.sh "${SCRIPT_PATH}/admin_installation.sh"
ADD ${GITHUB_RAW}/scripts/entrypoint.sh "${SCRIPT_PATH}/entrypoint.sh"
# Downloading nginx configuration files and fastcgi to PHP handling
ADD --chown=nginx:nginx etc/fastcgi.conf "/etc/nginx/fastcgi.conf"
ADD --chown=nginx:nginx etc/nginx.conf "/etc/nginx/http.d/moodle.conf"

# To set up the server, you will need to install necessary packages such as PHP, Nginx, and other packages for general server handling.
# If a user wants to use a different Moodle version, they can change the ${VERSION} argument inside the Dockerfile
# See more: https://docs.moodle.org/401/en/Installation_quick_guide
# See full installation guide: https://docs.moodle.org/401/en/Installing_Moodle
RUN export http_proxy=${HTTP_PROXY} &&\
    export https_proxy=${HTTP_PROXY} &&\
    apk update --no-cache &&\
    apk add \
    curl \
    su-exec \
    nginx \
    openldap-dev \
    php8 \
    php8-session \
    php8-xmlreader \
    php8-fileinfo \
    php8-sodium \
    php8-exif \
    php8-opcache \
    php8-iconv \
    php8-mbstring \
    php8-curl \
    php8-openssl \
    php8-tokenizer \
    php8-pecl-xmlrpc \
    php8-soap \
    php8-ctype \
    php8-zip \
    php8-gd \
    php8-simplexml \
    php8-dom \
    php8-xml \
    php8-intl \
    php8-json \
    php8-mysqli \
    php8-pdo_mysql \
    php8-ldap \
    php8-sockets \
    php8-fpm --no-cache --repository="http://dl-cdn.alpinelinux.org/alpine/edge/testing"

# Download the official Moodle tarball and its corresponding MD5 and SHA256 checksum files from moodle.org
RUN export http_proxy=${HTTP_PROXY} &&\
    export https_proxy=${HTTP_PROXY} &&\
    curl -fSL https://download.moodle.org/stable401/moodle-latest-401.tgz -OL &&\
    curl -fSL https://download.moodle.org/stable401/moodle-latest-401.tgz.md5 -OL &&\
    curl -fSL https://download.moodle.org/stable401/moodle-latest-401.tgz.sha256 -OL &&\
    # By running these commands, you can ensure that the downloaded file
    # has not been corrupted or tampered with during the download process.
    echo "$(grep -oE '[0-9a-f]{32}' moodle-latest-401.tgz.md5)  moodle-latest-401.tgz" | md5sum -c - &&\
    echo "$(grep -oE '[0-9a-f]{64}' moodle-latest-401.tgz.sha256)  moodle-latest-401.tgz" | sha256sum -c - &&\
    tar -xvzf /var/www/moodle-latest-401.tgz &&\
    # This scope changes the ownership and permissions of the Moodle
    # installation directory and moodledata directory.
    # Secure the Moodle files: It is vital that the files are not writeable by the web server user. For example, on Unix/Linux (as root):
    chown -R nginx:nginx "/var/www/moodle" &&\
    chmod -R 0755 "/var/www/moodle" &&\
    find "/var/www/moodle" -type f -exec chmod 0644 {} \; &&\
    # IMPORTANT: This directory must NOT be accessible directly via the web. This would be a serious security hole.
    # Do not try to place it inside your web root or inside your Moodle program files directory.
    # Moodle will not install. It can go anywhere else convenient.
    # See more: https://docs.moodle.org/401/en/Installing_Moodle
    mkdir "/var/www/moodledata" &&\
    chown -R nginx:nginx "/var/www/moodledata" &&\
    chmod -R 0775 "/var/www/moodledata" &&\
    find "/var/www/moodledata" -type f -exec chmod 0664 {} \; &&\
    # Delete unnecessary scripts, tarballs and their checksum files
    rm -rf /var/www/moodle-latest-* &&\
    # This scope set the scripts as executable scripts to run an runtime and buildtime tools 
    chmod +x "${SCRIPT_PATH}/admin_installation.sh" &&\
    chmod +x "${SCRIPT_PATH}/entrypoint.sh" &&\
    # These scripts will check if all PHP extensions are enabled
    # and set up the php.ini file with available environment variables
    sh <(curl -fsSL ${GITHUB_RAW}/scripts/check_extensions.sh) &&\
    sh <(curl -fsSL ${GITHUB_RAW}/scripts/php_config.sh) &&\
    sh <(curl -fsSL ${GITHUB_RAW}/scripts/configure_socket.sh) &&\
    # Override max post limit in nginx
    sed -i 's/user nginx/user nginx nginx/' /etc/nginx/nginx.conf &&\
    sed -i 's/client_max_body_size .*/client_max_body_size 1024m;/' /etc/nginx/nginx.conf &&\
    nginx -t &&\
    # Configure PHP-FPM to listen on a Unix socket instead of a TCP port, which is more secure and efficient
    sed -i 's/^\s*user = .*/user = nginx/' ${PHP_SOCKET_PATH} &&\
    sed -i 's/^\s*group = .*/group = nginx/' ${PHP_SOCKET_PATH} &&\
    sed -i 's/^\s*listen = .*/listen = \/run\/php8\/php-fpm8.sock/' ${PHP_SOCKET_PATH} &&\
    sed -i 's/^\s*;\s*listen.owner = .*/listen.owner = nginx/' ${PHP_SOCKET_PATH} &&\
    sed -i 's/^\s*;\s*listen.group = .*/listen.group = nginx/' ${PHP_SOCKET_PATH} &&\
    sed -i 's/^\s*;\s*listen.mode = .*/listen.mode = 0660/' ${PHP_SOCKET_PATH} &&\
    sed -i 's/^\s*;\s*security.limit_extensions = .*/security.limit_extensions = .php/' ${PHP_SOCKET_PATH} &&\
    php-fpm8 -tt &&\
    # Forward request and error logs to docker log collector
    ln -sf /dev/stdout /var/log/nginx/access.log &&\
    ln -sf /dev/stderr /var/log/nginx/error.log

# Moodle environment variables, you can set these envs using composer or terraform output
ENV MOODLE_LANG=""
ENV MOODLE_WWW=""
ENV MOODLE_DATADIR=""
ENV MOODLE_DB_TYPE=""
ENV MOODLE_DB_HOST=""
ENV MOODLE_DB_NAME=""
ENV MOODLE_DB_USER=""
ENV MOODLE_DB_PASSWORD=""
ENV MOODLE_ADMIN_USER=""
ENV MOODLE_ADMIN_PASSWORD=""

# Docker metadata contains information about the maintainer, such as the name, repository, and support email
# Please add any necessary information or correct any incorrect information
# See more: https://docs.docker.com/config/labels-custom-metadata/
LABEL name="Moodle" \
      description="Moodle is a free, online Learning Management system enabling educators to create their own private website filled with dynamic courses that extend learning, any time, anywhere." \
      version="4.1" \
      vendor="Moodle<moodle.org>" \
      maintainer="Junior L. Botelho<docker@juniorbotelho.org>" \
      url="https://github.com/juniorbotelho/moodle" \
      usage="https://github.com/juniorbotelho/moodle/wiki" \
      authors="https://github.com/juniorbotelho/moodle/contributors"

ENTRYPOINT [ "/bin/sh", "-c", "${SCRIPT_PATH}/entrypoint.sh" ]
