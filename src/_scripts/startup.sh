#!/bin/bash

python3 -u /etc/postfix/filter/main.py >>/etc/postfix/filter/filter.log &
