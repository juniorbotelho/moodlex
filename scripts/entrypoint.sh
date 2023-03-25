#!/bin/sh

exec /bin/sh -c /usr/sbin/php-fpm7
exec nginx -g "daemon off;"
