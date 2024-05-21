FROM ubuntu:20.04

# Prefill configurations
RUN echo "postfix postfix/mailname string kinoras.me" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections

# Install Postfix, Dovecot and other tools
RUN DEBIAN_FRONTEND=noninteractive apt update && \
    DEBIAN_FRONTEND=noninteractive apt upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt install -y \
        init nano net-tools wget postfix \
        apache2 apache2-utils mariadb-server mariadb-client php libapache2-mod-php \
        php-mysql php-net-ldap2 php-net-ldap3 php-imagick php-common php-gd php-imap \
        php-json php-curl php-zip php-xml php-mbstring php-bz2 php-intl php-gmp \
        php-net-smtp php-mail-mime mailutils \
         dovecot-imapd dovecot-pop3d && \
    mkdir /buildtmp

# Copy postfix files
COPY ./postfix /buildtmp/postfix

# Move and setup filters
RUN mv /buildtmp/postfix/lab /etc/postfix/lab && \
    /buildtmp/postfix/tmp_main.cf >> /etc/postfix/main.cf && \
    /buildtmp/postfix/tmp_master.cf >> /etc/postfix/master.cf

# Install Roundcube
RUN wget https://github.com/roundcube/roundcubemail/releases/download/1.6.6/roundcubemail-1.6.6-complete.tar.gz && \
    tar -xvf roundcubemail-1.6.6-complete.tar.gz && \
    rm roundcubemail-1.6.6-complete.tar.gz && \
    sudo mv roundcubemail-1.6.6 /var/www/html/mailbox && \
    sudo chown -R www-data:www-data /var/www/html/mailbox/ && \
    sudo chmod 755 -R /var/www/html/mailbox/

COPY ./roundcube/init.sql /buildtmp

RUN cat /buildtmp/init.sql | sudo mysql -u root

EXPOSE 25 80 110 143 465 587 143 993 995

CMD ["/sbin/init"]