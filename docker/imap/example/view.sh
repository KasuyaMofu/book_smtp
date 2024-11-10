#!/bin/bash

USER=$1

echo '--------------------------'
cat `ls -t1 /home/${USER}/Maildir/new/* | head -n 1`
echo '--------------------------'
