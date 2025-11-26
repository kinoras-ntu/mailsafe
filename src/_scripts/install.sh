# !/bin/bash

apt update
apt upgrade -y

# Install dependencies
sed "s/#.*//" /tmp/src/_dependencies/packages.txt | xargs apt install -y

# Install Python packages
pip3 install -r /tmp/src/_dependencies/requirements.txt

# Install PHP Composer
php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Download Roundcube
wget https://github.com/roundcube/roundcubemail/releases/download/1.6.6/roundcubemail-1.6.6-complete.tar.gz -O /tmp/roundcube.tar.gz

# Extract Roundcube
mkdir -p /var/www/html/mailbox
tar -xvf /tmp/roundcube.tar.gz -C /var/www/html/mailbox --strip-components=1

# Set Roundcube permissions
chown -R www-data:www-data /var/www/html/mailbox/
chmod 755 -R /var/www/html/mailbox/

# Clean up
rm /tmp/roundcube.tar.gz
