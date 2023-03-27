#!/bin/sh

# Read more: https://docs.moodle.org/401/en/Administration_via_command_line#Installation
export PATH="/bin:$PATH"
export http_proxy=${HTTP_PROXY}
export https_proxy=${HTTP_PROXY}

if [ ! -f /moodle/config.php ]; then
  echo "Keep calm! The database still be starting..."
  sleep 3
  # See more: https://docs.moodle.org/401/en/Administration_via_command_line#Installation
  su-exec nginx php7 moodle/admin/cli/install.php \
    --lang=${MOODLE_LANG:-"en"} \
    --wwwroot=${MOODLE_WWW:-"http://localhost:8080"} \
    --dataroot=${MOODLE_DATADIR:-"/var/www/moodledata"} \
    --dbtype=${MOODLE_DB_TYPE:-"mysqli"} \
    --dbhost=${MOODLE_DB_HOST:-"db"} \
    --dbname=${MOODLE_DB_NAME:-"moodle"} \
    --dbuser=${MOODLE_DB_USER:-"moodleuser"} \
    --dbpass=${MOODLE_DB_PASSWORD:-"moodlepw"} \
    --non-interactive \
    --skip-database \
    --agree-license
fi

if [ ! -f /moodle/config.php ]; then
  # finally, merge needed configurations inside the new config.php file
  # See more: https://docs.moodle.org/401/en/Nginx
  if [ $(cat moodle/config.php | grep -c "xsendfile = 'X-Accel-Redirect'") -eq 0 ]; then
    echo "\$CFG->xsendfile = 'X-Accel-Redirect';"   >> moodle/config.php
    echo "\$CFG->xsendfilealiases = array("         >> moodle/config.php
    echo "  '/dataroot/' => \$CFG->dataroot"        >> moodle/config.php
    echo ");"                                       >> moodle/config.php
  fi
fi
