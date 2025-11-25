FROM ubuntu:20.04

# Copy files
COPY ./src /tmp/src
RUN chmod -R 755 /tmp/src && \
    chmod +x /tmp/src/utils/conf.sh && \
    /tmp/src/utils/conf.sh

# Prefill configurations
RUN cat /tmp/src/postfix/preconfig | debconf-set-selections

# Install Postfix, Dovecot, Composer and other tools
RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
        init nano net-tools wget postfix rsyslog clamav-daemon apache2 apache2-utils mariadb-server \
        mariadb-client php libapache2-mod-php php-mysql php-net-ldap2 php-net-ldap3 php-imagick \
        php-common php-gd php-imap php-json php-curl php-zip php-xml php-mbstring php-bz2 php-intl \
        php-gmp php-net-smtp php-mail-mime mailutils dovecot-imapd dovecot-pop3d python3-pip \
        php-cli unzip dovecot-sieve dovecot-managesieved opendkim opendkim-tools && \ 
    DEBIAN_FRONTEND=noninteractive pip3 install openai dkimpy pyclamd python-dotenv mysql-connector-python && \
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" && \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Setup Postfix
RUN mv /tmp/src/postfix/filter /etc/postfix/filter && \
    cat /tmp/src/postfix/main.cf >> /etc/postfix/main.cf && \
    cat /tmp/src/postfix/master.cf >> /etc/postfix/master.cf && \
    freshclam

# Install Roundcube
RUN wget https://github.com/roundcube/roundcubemail/releases/download/1.6.6/roundcubemail-1.6.6-complete.tar.gz -O /tmp/roundcube.tar.gz && \
    mkdir -p /var/www/html/mailbox && \
    tar -xvf /tmp/roundcube.tar.gz -C /var/www/html/mailbox --strip-components=1 && \
    rm /tmp/roundcube.tar.gz && \
    chown -R www-data:www-data /var/www/html/mailbox/ && \
    chmod 755 -R /var/www/html/mailbox/

# Setup Roundcube & Admin Panel
RUN service mysql start && \
    cat /tmp/src/roundcube/setup.sql | mysql -u root && \
    mysql roundcube < /var/www/html/mailbox/SQL/mysql.initial.sql && \
    mysql app < /tmp/src/roundcube/app.sql && \
    service mysql stop && \
    cat /tmp/src/roundcube/roundcube.conf > /etc/apache2/sites-available/roundcube.conf && \
    a2ensite roundcube.conf && \
    echo "date.timezone = Asia/Macau" >> /etc/php/7.4/apache2/php.ini && \
    mv /tmp/src/admin /var/www/html/admin && \
    mkdir -p /etc/postfix/filter/backup && \
    mv /tmp/src/roundcube/config.inc.php /var/www/html/mailbox/config/config.inc.php && \
    composer require -d /var/www/html/mailbox/ -n kinoras/rcplus

# Setup Dovecot & Dovecot Sieve
RUN cat /tmp/src/dovecot/dovecot.conf >> /etc/dovecot/dovecot.conf && \
    chmod a+w /var/mail && \
    mkdir -p /etc/dovecot/sieve && \
    mv /tmp/src/dovecot/sieve/default.sieve /etc/dovecot/sieve/default.sieve && \
    sievec /etc/dovecot/sieve/default.sieve && \
    mv -f /tmp/src/dovecot/conf.d/* /etc/dovecot/conf.d/

# Setup Startup Script
RUN mv /tmp/src/utils/startup.sh /startup.sh && \
    chmod +x /startup.sh 

# Cleanup
RUN rm -rf /tmp/src

EXPOSE 25 80 110 143 465 587 143 993 995

CMD ["/sbin/init"]
