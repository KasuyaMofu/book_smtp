#!/bin/bash

postfix start
tail ---disable-inotify -s 3 -f /var/log/postfix 