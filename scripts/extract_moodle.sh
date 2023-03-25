#!/bin/sh

PATH="/var/www/html"

/bin/tar -xvzf "${PATH}/moodle-latest-401.tgz"
/bin/rm -rf "${PATH}/moodle-*.tgz*"
