#!/bin/sh

if [ ! -z "$DB_HOST" ]
then
   if [ -z "$DB_USER" ] || [ -z "$DB_PASS" ] || [ -z "$DB_NAME" ] || [ -z "$VBX_SALT" ]
   then
     >&2 echo "Ensure the following environment variables are set: DB_HOST, DB_USER, DB_PASS, DB_NAME, VBX_SALT"
     exit 1;
   fi

   cat >/var/www/site/OpenVBX/config/database.php <<EOL
   <?php
   \$active_group = 'default';
   \$active_record = TRUE;
   \$db['default']['username'] = '$DB_USER';
   \$db['default']['password'] = '$DB_PASS';
   \$db['default']['hostname'] = '$DB_HOST';
   \$db['default']['database'] = '$DB_NAME';
   \$db['default']['dbdriver'] = 'mysqli';
   \$db['default']['dbprefix'] = '';
   \$db['default']['pconnect'] = FALSE;
   \$db['default']['db_debug'] = FALSE;
   \$db['default']['cache_on'] = FALSE;
   \$db['default']['cachedir'] = '';
   \$db['default']['char_set'] = 'utf8';
   \$db['default']['dbcollat'] = 'utf8_general_ci';
/* Generated from docker install */
EOL
chown root:www-data /var/www/site/OpenVBX/config/database.php

   cat >/var/www/site/OpenVBX/config/openvbx.php <<EOL
<?php
\$config['salt'] = '$VBX_SALT';
/* Generated from docker install */
EOL
  chown root:www-data /var/www/site/OpenVBX/config/openvbx.php

  echo "Generated files:";
  echo "/var/www/site/OpenVBX/config/database.php"
  cat /var/www/site/OpenVBX/config/database.php
  echo ""
  echo "/var/www/site/OpenVBX/config/openvbx.php"
  cat /var/www/site/OpenVBX/config/openvbx.php
else

  echo "Commencing fresh startup"
fi

if [ $? -ne 0 ]
then
	>&2 echo "Generating the HTML failed"
	exit 1;
fi

/usr/sbin/apache2ctl -D FOREGROUND
