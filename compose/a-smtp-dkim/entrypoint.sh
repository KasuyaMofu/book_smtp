#!/bin/bash

redis-server --daemonize yes
sudo -u rspamd /usr/bin/rspamd -c /etc/rspamd/rspamd.conf
postfix start
tail ---disable-inotify -s 3 -f /var/log/postfix 