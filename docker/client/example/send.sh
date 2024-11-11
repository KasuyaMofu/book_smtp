#!/bin/bash

if [ -z "${4}" ]; then
  echo "Usage: <from> <to> <title> <smtp_server> [envelope_from]"
  exit 1
else
  TITLE=${1}
  FROM=${2}
  FROM_DOMAIN=`echo ${FROM} | awk -F@ '{print $2}'`
  TO=${3}
  SMTP_SERVER=${4}
fi

if [ -z "${5}" ]; then
  ENVELOPE_FROM=${FROM}
else
  ENVELOPE_FROM=${5}
fi

echo "# telnet ${SMTP_SERVER} 25"
echo '--------------------------'
{ sleep 0.1; echo "HELO ${FROM_DOMAIN}"; \
  sleep 0.1; echo "MAIL FROM: ${ENVELOPE_FROM}";  \
  sleep 0.1; echo "RCPT TO:   ${TO}";    \
  sleep 0.1; echo 'DATA';                \
  sleep 0.1; echo "Message-ID: <"`date +"%Y%m%d%H%M%S"`".${RANDOM}@${FROM_DOMAIN}>"; \
  sleep 0.1; date +"Date: %a, %d %b %Y %H:%M:%S +0900";  \
  sleep 0.1; echo "From: ${FROM}";       \
  sleep 0.1; echo "To:   ${TO}";         \
  sleep 0.1; echo "Subject: ${TITLE} (mail from ${FROM})";  \
  sleep 0.1; echo '';            \
  sleep 0.1; echo "Hello ${TO}!"; \
  sleep 0.1; echo '.';           \
  sleep 0.2; echo 'QUIT';        \
} | tee /dev/stderr | telnet ${SMTP_SERVER} 25
echo '--------------------------'
