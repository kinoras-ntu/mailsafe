# !/bin/bash

# Configure Dovecot: Mailboxes
cat /tmp/src/dovecot/dovecot.conf >>/etc/dovecot/dovecot.conf

chmod a+w /var/mail

# Setup Dovecot Sieve
mkdir -p /etc/dovecot/sieve
mv /tmp/src/dovecot/sieve/default.sieve /etc/dovecot/sieve/default.sieve
sievec /etc/dovecot/sieve/default.sieve

# Overwrite Dovecot configurations: Plugin-related
mv -f /tmp/src/dovecot/conf.d/* /etc/dovecot/conf.d/
