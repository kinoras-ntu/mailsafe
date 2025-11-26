# !/bin/bash

# Initialize database
service mysql start
cat /tmp/src/roundcube/setup.sql | mysql -u root
mysql roundcube </var/www/html/mailbox/SQL/mysql.initial.sql
mysql app </tmp/src/roundcube/app.sql
service mysql stop

# Configure Roundcube
cat /tmp/src/roundcube/roundcube.conf >/etc/apache2/sites-available/roundcube.conf
a2ensite roundcube.conf
mkdir -p /etc/postfix/filter/backup
mv /tmp/src/roundcube/config.inc.php /var/www/html/mailbox/config/config.inc.php

# Set timezone
echo "date.timezone = Asia/Macau" >>/etc/php/7.4/apache2/php.ini

# Install Admin Panel
mv /tmp/src/admin /var/www/html/admin

# Install custom RCPlus plugins
composer require -d /var/www/html/mailbox/ -n kinoras/rcplus
