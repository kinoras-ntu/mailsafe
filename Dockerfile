FROM ubuntu:20.04

# Copy files
COPY ./temp /buildtmp
RUN chmod -R 755 /buildtmp && \
    chmod +x /buildtmp/utils/conf.sh && \
    /buildtmp/utils/conf.sh

# Prefill configurations
RUN echo "postfix postfix/mailname string kinoras.me" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections

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
RUN mv /buildtmp/postfix/lab /etc/postfix/lab && \
    cat /buildtmp/postfix/tmp_main.cf >> /etc/postfix/main.cf && \
    cat /buildtmp/postfix/tmp_master.cf >> /etc/postfix/master.cf && \
    freshclam

# Install Roundcube
RUN wget https://github.com/roundcube/roundcubemail/releases/download/1.6.6/roundcubemail-1.6.6-complete.tar.gz && \
    tar -xvf roundcubemail-1.6.6-complete.tar.gz && \
    rm roundcubemail-1.6.6-complete.tar.gz && \
    mv roundcubemail-1.6.6 /var/www/html/mailbox && \
    chown -R www-data:www-data /var/www/html/mailbox/ && \
    chmod 755 -R /var/www/html/mailbox/

# Setup Roundcube & Admin Panel
RUN service mysql start && \
    cat /buildtmp/roundcube/init.sql | mysql -u root && \
    mysql roundcube < /var/www/html/mailbox/SQL/mysql.initial.sql && \
    mysql junox < /buildtmp/roundcube/junox.sql && \
    service mysql stop && \
    cat /buildtmp/roundcube/roundcube.conf > /etc/apache2/sites-available/roundcube.conf && \
    a2ensite roundcube.conf && \
    echo "date.timezone = Asia/Macau" >> /etc/php/7.4/apache2/php.ini && \
    mv /buildtmp/admin /var/www/html/admin && \
    mkdir /etc/postfix/lab/backup && \
    mv /buildtmp/roundcube/config.inc.php /var/www/html/mailbox/config/config.inc.php && \
    composer require -d /var/www/html/mailbox/ -n kinoras/rcplus

# Setup Dovecot & Dovecot Sieve
RUN cat /buildtmp/dovecot/dovecot.conf >> /etc/dovecot/dovecot.conf && \
    chmod a+w /var/mail && \
    mkdir /etc/dovecot/sieve && \
    mv /buildtmp/dovecot/sieve/default.sieve /etc/dovecot/sieve/default.sieve && \
    sievec /etc/dovecot/sieve/default.sieve && \
    mv -f /buildtmp/dovecot/conf.d/* /etc/dovecot/conf.d/

RUN chmod +x /buildtmp/utils/startup.sh && \
    mv /buildtmp/utils/startup.sh /startup.sh && \
    rm -rf /buildtmp

EXPOSE 25 80 110 143 465 587 143 993 995

CMD ["/sbin/init"]