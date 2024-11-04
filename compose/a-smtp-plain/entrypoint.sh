#!/bin/bash

postmap /etc/postfix/transport
postfix start

tail ---disable-inotify -s 3 -f /var/log/postfix 