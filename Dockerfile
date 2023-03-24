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

ADD --chown=root:root scripts /etc/scripts
ADD --chown=root:root https://download.moodle.org/stable401/moodle-4.1.2.tgz .
ADD --chown=root:root https://download.moodle.org/stable401/moodle-4.1.2.tgz.md5 .
ADD --chown=root:root https://download.moodle.org/stable401/moodle-4.1.2.tgz.sha256 .

# Setup needed packages such as PHP, Nginx and another packages for general server handling
# Wether user can use other moodle version, him can change ${VERSION} argument inside Dockerfile
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
      md5sum -c "moodle-4.1.2.tgz.md5" &&\
      sha256sum -c "moodle-4.1.2.tgz.sha256" &&\
      tar -xvzf "moodle-4.1.2.tgz" &&\
      rm -rf "moodle-4.1.2.tgz" &&\
      mkdir "/home/moodledata"

# This block changes the ownership and permissions of the Moodle
# installation directory and moodledata directory.
RUN   chown -R root:root "/var/www/html/moodle" &&\
      chmod -R 0755 "/var/www/html/moodle" &&\
      chmod -R 0755 "/home/moodledata"

# These scripts will check if all PHP extensions are enabled
# and set up the php.ini file with available environment variables
RUN   sh /etc/scripts/check_extensions.sh &&\
      sh /etc/scripts/php.sh

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
