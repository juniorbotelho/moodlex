#!/bin/sh

# This condition creates the Unix socket if 'php-fpm7.sock' does not already exist.
# This fixes an issue where Nginx starts but does not serve content
if [ ! -d "/run/php7" ] || [ ! -S "/run/php7/php-fpm7.sock" ]; then
    mkdir "/run/php7"
    touch "/run/php7/php-fpm7.sock"
    # This fixes an issue where Nginx starts but does not serve content
    chmod 660 "/run/php7/php-fpm7.sock"
    chown nginx:nginx "/run/php7/php-fpm7.sock"
fi
