#!/bin/bash

# Move filter scripts
mv /tmp/src/postfix/filter /etc/postfix/filter

# Configure Postfix
cat /tmp/src/postfix/main.cf >>/etc/postfix/main.cf
cat /tmp/src/postfix/master.cf >>/etc/postfix/master.cf

# Update ClamAV database
freshclam
