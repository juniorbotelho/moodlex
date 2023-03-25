<?php
  // Setting Moodle and Nginx to use XSendfile functionality is a big win as it frees PHP
  // from delivering files allowing Nginx to do what it does best, i.e. deliver files.
  // Enable xsendfile for Nginx in Moodles config.php, this is documented in the config-dist.php,
  // a minimal configuration look like this:
  $CFG->xsendfile = 'X-Accel-Redirect';
  $CFG->xsendfilealiases = array(
      '/dataroot/' => $CFG->dataroot
  );
?>
