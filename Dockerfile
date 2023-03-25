# syntax=docker.io/docker/dockerfile:1.2
ARG ALPINE_VERSION=3.17
FROM docker.io/alpine:${ALPINE_VERSION} as Moodle
WORKDIR "/var/www/html"

# Customize the environment during both execution and build time by modifying the environment variables added to the container's shell
# When building your image, make sure to set the 'TZ' environment variable to your desired time zone location, for example 'America/Sao_Paulo'
# See more: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
ARG TZ="America/Sao_Paulo"
ARG GITHUB_RAW="https://raw.githubusercontent.com/juniorbotelho/moodle/main"

# To set up the server, you will need to install necessary packages such as PHP, Nginx, and other packages for general server handling.
# If a user wants to use a different Moodle version, they can change the ${VERSION} argument inside the Dockerfile
# See more: https://docs.moodle.org/401/en/Installation_quick_guide
# See full installation guide: https://docs.moodle.org/401/en/Installing_Moodle
RUN apk update &&\
    apk add nginx openldap-dev \
    php7 \
    php7-iconv \
    php7-mbstring \
    php7-curl \
    php7-openssl \
    php7-tokenizer \
    php7-xmlrpc \
    php7-soap \
    php7-ctype \
    php7-zip \
    php7-gd \
    php7-simplexml \
    php7-dom \
    php7-xml \
    php7-intl \
    php7-json \
    php7-pgsql \
    php7-mysqli \
    php7-pdo_pgsql \
    php7-pdo_mysql \
    php7-ldap \
    php7-sockets \
    php7-fpm --no-cache --repository="http://dl-cdn.alpinelinux.org/alpine/edge/testing"

ENV SCRIPT_PATH="/etc/scripts"
ENV PHP_SOCKET_CONF="/etc/php7/php-fpm.d/www.conf"
ENV PHP_MEMORY_LIMIT=256M
ENV PHP_POST_MAX_SIZE=16M
ENV PHP_UPLOAD_MAX_FILESIZE=1024M

# Download custom scripts that will be run after build or when run a new container of this image
ADD --chown=root:root scripts/check_extensions.sh "${SCRIPT_PATH}/check_extensions.sh"
ADD --chown=root:root scripts/configure_socket.sh "${SCRIPT_PATH}/configure_socket.sh"
ADD --chown=root:root scripts/entrypoint.sh "${SCRIPT_PATH}/entrypoint.sh"
ADD --chown=root:root scripts/extract_moodle.sh "${SCRIPT_PATH}/extract_moodle.sh"
ADD --chown=root:root scripts/php.sh "${SCRIPT_PATH}/php.sh"
# Downloading nginx configuration files and fastcgi to PHP handling
ADD --chown=root:root ${GITHUB_RAW}/etc/fastcgi.conf "/etc/nginx/fastcgi.conf"
ADD --chown=root:root ${GITHUB_RAW}/etc/nginx.conf "/etc/nginx/http.d/moodle.conf"

# Download the official Moodle tarball and its corresponding MD5 and SHA256 checksum files from moodle.org
ADD --chown=root:root https://download.moodle.org/stable401/moodle-4.1.2.tgz .
ADD --chown=root:root https://download.moodle.org/stable401/moodle-4.1.2.tgz.md5 .
ADD --chown=root:root https://download.moodle.org/stable401/moodle-4.1.2.tgz.sha256 .

# By running these commands, you can ensure that the downloaded file
# has not been corrupted or tampered with during the download process.
RUN echo "$(grep -oE '[0-9a-f]{32}' moodle-4.1.2.tgz.md5)  moodle-4.1.2.tgz" | md5sum -c - &&\
    echo "$(grep -oE '[0-9a-f]{64}' moodle-4.1.2.tgz.sha256)  moodle-4.1.2.tgz" | sha256sum -c - &&\
    mkdir "/var/www/html/{moodle,moodledata}"

# This block changes the ownership and permissions of the Moodle
# installation directory and moodledata directory.
RUN chmod +x "${SCRIPT_PATH}/check_extensions.sh" &&\
    chmod +x "${SCRIPT_PATH}/configure_socket.sh" &&\
    chmod +x "${SCRIPT_PATH}/entrypoint.sh" &&\
    chmod +x "${SCRIPT_PATH}/extract_moodle.sh" &&\
    chmod +x "${SCRIPT_PATH}/php.sh"

# Configure PHP-FPM to listen on a Unix socket instead of a TCP port, which is more secure and efficient
RUN sed -i 's/^\s*listen = 127.0.0.1:9000/listen = \/run\/php7\/php-fpm7.sock/' ${PHP_SOCKET_CONF} &&\
    sed -i 's/^\s*;\s*listen.owner = nobody/listen.owner = nginx/' ${PHP_SOCKET_CONF} &&\
    sed -i 's/^\s*;\s*listen.group = nobody/listen.group = nginx/' ${PHP_SOCKET_CONF} &&\
    sed -i 's/^\s*;\s*listen.mode = 0660/listen.mode = 0660/' ${PHP_SOCKET_CONF}

# These scripts will check if all PHP extensions are enabled
# and set up the php.ini file with available environment variables
RUN sh "${SCRIPT_PATH}/check_extensions.sh" &&\
    sh "${SCRIPT_PATH}/php.sh"

# Forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log &&\
    ln -sf /dev/stderr /var/log/nginx/error.log

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
