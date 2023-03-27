#!/bin/sh

# Read more: https://docs.moodle.org/401/en/Administration_via_command_line#Installation
export PATH="/bin:$PATH"
export http_proxy=${HTTP_PROXY}
export https_proxy=${HTTP_PROXY}

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
