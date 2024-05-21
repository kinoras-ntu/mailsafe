FROM ubuntu:20.04

# Prefill configurations
RUN echo "postfix postfix/mailname string kinoras.me" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections

# Install Postfix, Dovecot and other tools
RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
        init nano net-tools wget postfix rsyslog \
        apache2 apache2-utils mariadb-server mariadb-client php libapache2-mod-php php-mysql \
        php-net-ldap2 php-net-ldap3 php-imagick php-common php-gd php-imap php-json php-curl \
        php-zip php-xml php-mbstring php-bz2 php-intl php-gmp php-net-smtp php-mail-mime \
        mailutils dovecot-imapd dovecot-pop3d python3-pip php-cli unzip && \ 
    DEBIAN_FRONTEND=noninteractive pip3 install openai && \
    mkdir /buildtmp && \
    php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');" \
    php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer

# Copy Files
COPY ./temp /buildtmp

# Move and setup filters
RUN chmod -R 755 /buildtmp && \
    mv /buildtmp/postfix/lab /etc/postfix/lab && \
    cat /buildtmp/postfix/tmp_main.cf >> /etc/postfix/main.cf && \
    cat /buildtmp/postfix/tmp_master.cf >> /etc/postfix/master.cf

# Install Roundcube
RUN wget https://github.com/roundcube/roundcubemail/releases/download/1.6.6/roundcubemail-1.6.6-complete.tar.gz && \
    tar -xvf roundcubemail-1.6.6-complete.tar.gz && \
    rm roundcubemail-1.6.6-complete.tar.gz && \
    mv roundcubemail-1.6.6 /var/www/html/mailbox && \
    chown -R www-data:www-data /var/www/html/mailbox/ && \
    chmod 755 -R /var/www/html/mailbox/

# Setup Roundcube
RUN service mysql start && \
    cat /buildtmp/roundcube/init.sql | mysql -u root && \
    mysql roundcube < /var/www/html/mailbox/SQL/mysql.initial.sql && \
    service mysql stop && \
    cat /buildtmp/roundcube/roundcube.conf > /etc/apache2/sites-available/roundcube.conf && \
    a2ensite roundcube.conf && \
    echo "date.timezone = Asia/Macau" >> /etc/php/7.4/apache2/php.ini && \
    mv /buildtmp/roundcube/config.inc.php /var/www/html/mailbox/config/config.inc.php

EXPOSE 25 80 110 143 465 587 143 993 995

CMD ["/sbin/init"]