#!/bin/sh

PATH="/var/www/html"

/bin/tar -xvzf "${PATH}/moodle-latest-401.tgz"
/bin/rm -rf "${PATH}/moodle-*.tgz*"

# Secure the Moodle files: It is vital that the files are not writeable by the web server user. For example, on Unix/Linux (as root):
/bin/chown -R root "${PATH}/moodle"
/bin/chmod -R 0755 "${PATH}/moodle"
# IMPORTANT: This directory must NOT be accessible directly via the web. This would be a serious security hole.
# Do not try to place it inside your web root or inside your Moodle program files directory.
# Moodle will not install. It can go anywhere else convenient.
# See more: https://docs.moodle.org/401/en/Installing_Moodle
/bin/chmod -R 0777 "${PATH}/moodledata"
