# Read more: https://docs.moodle.org/401/en/Administration_via_command_line#Installation
export PATH="/bin:$PATH"
export http_proxy=${HTTP_PROXY}
export https_proxy=${HTTP_PROXY}

exec su-exec nginx php7 moodle/admin/cli/install.php \
  --chmod=2770 \
  --lang=${MOODLE_LANG:-"en"} \
  --wwwroot=${MOODLE_WWW:-"http://127.0.0.1:8080"} \
  --dataroot=${MOODLE_DATADIR:-"/var/www/moodledata"} \
  --dbtype=${MOODLE_DB_TYPE:-"pgsql"} \
  --dbhost=${MOODLE_DB_HOST:-"db"} \
  --dbname=${MOODLE_DB_NAME:-"moodle"} \
  --dbuser=${MOODLE_DB_USER:-"moodleuser"} \
  --dbpass=${MOODLE_DB_PASSWORD:-"moodlepw"} \
  --fullname=${MOODLE_SITE_FULLNAME:-"Moodle LMS"} \
  --shortname=${MOODLE_SITE_SHORTNAME:-"Moodle"} \
  --adminuser=${MOODLE_ADMIN_USER:-"admin"} \
  --adminpass=${MOODLE_ADMIN_PASSWORD:-"admin"} \
  --adminemail=${MOODLE_ADMIN_EMAIL:-"admin@localhost.local"} \
  --supportemail=${MOODLE_SUPPORT_EMAIL:-"support@localhost.local"} \
  --non-interactive \
  --skip-database \
  --agree-license &&\
  # finally, merge needed configurations inside the new config.php file
  su-exec nginx echo $(cat /tmp/config.php) > moodle/config.php
