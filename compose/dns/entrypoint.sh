#!/bin/bash

unbound -c /etc/unbound/unbound.conf &
tail -f  /etc/unbound/var/log/unbound.log | grep --line-buffered -e ".test. A" -e "10.in-addr.arpa. PTR"