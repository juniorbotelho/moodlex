#!/bin/sh

# This condition creates the Unix socket if 'php-fpm8.sock' does not already exist.
# This fixes an issue where Nginx starts but does not serve content
if [ ! -d "/run/php8" ] || [ ! -S "/run/php8/php-fpm8.sock" ]; then
    mkdir "/run/php8"
    touch "/run/php8/php-fpm8.sock"
    # This fixes an issue where Nginx starts but does not serve content
    chmod 660 "/run/php8/php-fpm8.sock"
    chown nginx:nginx "/run/php8/php-fpm8.sock"
fi
