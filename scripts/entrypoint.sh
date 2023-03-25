#!/bin/sh

PHP_BIN="/usr/sbin"
SCRIPT_PATH="/etc/scripts"

sh ${SCRIPT_PATH}/configure_socket.sh
sh ${SCRIPT_PATH}/check_extensions.sh
sh ${SCRIPT_PATH}/extract_moodle.sh

exec sh ${PHP_BIN}/php-fpm7 &&\
     nginx -g "daemon off;"
