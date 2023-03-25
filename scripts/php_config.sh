#!/bin/sh

sed -i 's/memory_limit = .*/memory_limit = 128M/' /etc/php7/php.ini
sed -i 's/session.save_handler = redis/session.save_handler = files/' /etc/php7/php.ini
sed -i 's/file_uploads = .*/file_uploads = On/'
sed -i 's/session.auto_start = .*/session.auto_start = Off/' /etc
sed -i 's/post_max_size = .*/post_max_size = 16M/' /etc/php7
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 1024M/' /etc/php7/php.ini
sed -i 's/;max_input_vars = .*/max_input_vars = 5000/' /etc/php7/php.ini
sed -i 's/;session.save_path = .*/session.save_path = "\/tmp"/' /etc/php7/php.ini
