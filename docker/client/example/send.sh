#!/bin/bash

if [ -z "${3}" ]; then
  echo "Usage: <from> <to> <smtp_server> [envelope_from]"
  exit 1
else
  FROM=${1}
  FROM_DOMAIN=`echo ${FROM} | awk -F@ '{print $2}'`
  TO=${2}
  SMTP_SERVER=${3}
fi

if [ -z "${4}" ]; then
  ENVELOPE_FROM=${FROM}
else
  ENVELOPE_FROM=${4}
fi

echo "# telnet ${SMTP_SERVER} 25"

{ sleep 0.1; echo "HELO ${FROM_DOMAIN}"; \
  sleep 0.1; echo "MAIL FROM: ${ENVELOPE_FROM}";  \
  sleep 0.1; echo "RCPT TO:   ${TO}";    \
  sleep 0.1; echo 'DATA';                \
  sleep 0.1; echo "Message-ID: <"`date +"%Y%m%d%H%M%S"`".${RANDOM}@${FROM_DOMAIN}>"; \
  sleep 0.1; date +"Date: %a, %d %b %Y %H:%M:%S +0900";  \
  sleep 0.1; echo "From: ${FROM}";       \
  sleep 0.1; echo "To:   ${TO}";         \
  sleep 0.1; echo "Subject: test mail from ${FROM}!";  \
  sleep 0.1; echo '';            \
  sleep 0.1; echo "Hello ${TO}!"; \
  sleep 0.1; echo '.';           \
  sleep 0.1; echo 'QUIT';        \
} | tee /dev/stderr | telnet ${SMTP_SERVER} 25
