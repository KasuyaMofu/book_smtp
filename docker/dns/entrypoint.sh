#!/bin/bash

unbound -c /etc/unbound/unbound.conf &
tail -f  /etc/unbound/var/log/unbound.log | grep --line-buffered -vF "rspamd.com"