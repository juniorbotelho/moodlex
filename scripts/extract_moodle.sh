#!/bin/sh

PATH="/var/www/html"

/bin/tar -xvzf "${PATH}/moodle-4.1.2.tgz"
/bin/rm -rf "${PATH}/moodle-*.tgz*"
/usr/bin/php7 "${PATH}/moodle/install.php"
