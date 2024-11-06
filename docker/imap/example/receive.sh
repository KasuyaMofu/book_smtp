#!/bin/bash

USER=$1

cat `ls -t1 /home/${USER}/Maildir/new/* | head -n 1`