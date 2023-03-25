#!/bin/sh

SCRIPT_PATH="/etc/scripts"

sh ${SCRIPT_PATH}/configure_socket.sh
sh ${SCRIPT_PATH}/check_extensions.sh
sh ${SCRIPT_PATH}/extract_moodle.sh

/bin/sh -c /usr/sbin/php-fpm7

exec nginx -g "daemon off;"
