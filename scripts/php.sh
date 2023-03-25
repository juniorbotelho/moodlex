#!/bin/sh

sed -i 's/memory_limit = .*/memory_limit = ${PHP_MEMORY_LIMIT:-128M}/' /etc/php7/php.ini
sed -i 's/session.save_handler = redis/session.save_handler = files/' /etc/php7/php.ini
sed -i 's/file_uploads = .*/file_uploads = On/'
sed -i 's/session.auto_start = .*/session.auto_start = Off/' /etc
sed -i 's/post_max_size = .*/post_max_size = ${PHP_POST_MAX_SIZE:-16M}/' /etc/php7
sed -i 's/upload_max_filesize = .*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE:-256M}/' /etc/php7/php.ini
sed -i 's/max_input_vars = .*/max_input_vars = ${PHP_MAX_INPUT_VARS:-5000}/' /etc/php7/php.ini
