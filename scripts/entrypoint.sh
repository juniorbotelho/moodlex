#!/bin/sh

/bin/sh -c /usr/sbin/php-fpm8

exec nginx -g "daemon off;"
