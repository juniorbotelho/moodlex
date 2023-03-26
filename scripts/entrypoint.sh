#!/bin/sh

/bin/sh -c /usr/sbin/php-fpm7
/bin/sh -c /etc/scripts/admin-install

exec nginx -g "daemon off;"
