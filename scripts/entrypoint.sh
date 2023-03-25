#!/bin/sh

export PATH="/usr/sbin:$PATH"

./configure_socket.sh
./check_extensions.sh
./extract_moodle.sh

exec sh php-fpm7 &&\
     nginx -g "daemon off;"
