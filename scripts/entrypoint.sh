#!/bin/sh

/bin/sh -c /usr/sbin/php-fpm7
/bin/sh -c /etc/scripts/admin_installation.sh

exec nginx -g "daemon off;"
