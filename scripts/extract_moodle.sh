#!/bin/sh

PATH="/var/www/html"

exec tar -xvzf "${PATH}/moodle-4.1.2.tgz" &&\
     rm -rf "${PATH}/moodle-*.tgz*" &&
     php7 "${PATH}/moodle/install.php"
