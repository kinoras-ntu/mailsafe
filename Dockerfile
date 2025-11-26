FROM ubuntu:20.04

# Disable interactive frontend
ARG DEBIAN_FRONTEND=noninteractive

# Copy files
COPY ./src ./.env /tmp/src/
RUN chmod -R 755 /tmp/src

# Initialize
RUN /tmp/src/_scripts/init.sh

# Install dependencies
RUN /tmp/src/_scripts/install.sh

# Setup Postfix
RUN /tmp/src/_scripts/setup-postfix.sh

# Setup Roundcube & Admin Panel
RUN /tmp/src/_scripts/setup-roundcube.sh

# Setup Dovecot & Dovecot Sieve
RUN /tmp/src/_scripts/setup-dovecot.sh

# Cleanup
RUN rm -rf /tmp/src

EXPOSE 25 80 110 143 465 587 143 993 995

CMD ["/sbin/init"]
