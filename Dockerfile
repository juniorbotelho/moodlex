# syntax=docker.io/docker/dockerfile:1.2
ARG ALPINE_VERSION=3.17
FROM docker.io/alpine:${ALPINE_VERSION} as Moodle
WORKDIR "/var/www/html"

# Customize the environment during both execution and build time by modifying the environment variables added to the container's shell
# When building your image, make sure to set the 'TZ' environment variable to your desired time zone location, for example 'America/Sao_Paulo'
# See more: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List
ARG TZ="America/New_York"
ARG MEMORY_LIMIT=256M
ARG POST_MAX_SIZE=16M
ARG UPLOAD_MAX_FILESIZE=1024M

# Download custom scripts that will be run after build or when run a new container of this image
ADD --chown=root:root https://raw.githubusercontent.com/juniorbotelho/moodle/main/scripts/check_extensions.sh "/etc/scripts/check_extensions.sh"
ADD --chown=root:root https://raw.githubusercontent.com/juniorbotelho/moodle/main/scripts/php.sh "/etc/scripts/php.sh"

# Download the official Moodle tarball and its corresponding MD5 and SHA256 checksum files from moodle.org
ADD --chown=root:root https://download.moodle.org/stable401/moodle-4.1.2.tgz .
ADD --chown=root:root https://download.moodle.org/stable401/moodle-4.1.2.tgz.md5 .
ADD --chown=root:root https://download.moodle.org/stable401/moodle-4.1.2.tgz.sha256 .

# To set up the server, you will need to install necessary packages such as PHP, Nginx, and other packages for general server handling.
# If a user wants to use a different Moodle version, they can change the ${VERSION} argument inside the Dockerfile
# See more: https://docs.moodle.org/401/en/Installation_quick_guide
# See full installation guide: https://docs.moodle.org/401/en/Installing_Moodle
RUN   apk update &&\
      apk add nginx openldap-dev php7 \
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
      php7-fpm --no-cache --repository="http://dl-cdn.alpinelinux.org/alpine/edge/testing" &&\
      # By running these commands, you can ensure that the downloaded file
      # has not been corrupted or tampered with during the download process.
      echo "$(grep -oE '[0-9a-f]{32}' moodle-4.1.2.tgz.md5)  moodle-4.1.2.tgz" | md5sum -c - &&\
      echo "$(grep -oE '[0-9a-f]{64}' moodle-4.1.2.tgz.sha256)  moodle-4.1.2.tgz" | sha256sum -c - &&\
      tar -xvzf "moodle-4.1.2.tgz" &&\
      rm -rf "moodle-4.1.2.tgz" &&\
      mkdir "/home/moodledata"

# This block changes the ownership and permissions of the Moodle
# installation directory and moodledata directory.
RUN   chown -R root:root "/var/www/html/moodle" &&\
      chmod -R 0755 "/var/www/html/moodle" &&\
      chmod -R 0755 "/home/moodledata" &&\
      chmod +x "/etc/scripts/check_extensions.sh" &&\
      chmod +x "/etc/scripts/php.sh"

# These scripts will check if all PHP extensions are enabled
# and set up the php.ini file with available environment variables
RUN   sh "/etc/scripts/check_extensions.sh" &&\
      sh "/etc/scripts/php.sh"

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
