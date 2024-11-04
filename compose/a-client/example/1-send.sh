#!/bin/bash
echo "# telnet plain.smtp.a.test 25"

{ sleep 0.1; echo 'HELO a.test'; \
  sleep 0.1; echo 'MAIL FROM: test@a.test'; \
  sleep 0.1; echo 'RCPT TO:   user1@imap.b.test'; \
  sleep 0.1; echo 'DATA';\
  sleep 0.1; echo 'Message-ID: <1-send-sh@mail.test>;'\ 
  sleep 0.1; date -u +"Date: %a, %d %b %Y %H:%M:%S +0000"; \
  sleep 0.1; echo 'From: test@mail.test'; \
  sleep 0.1; echo 'To: user1@imap.b.test'; \
  sleep 0.1; echo 'Subject: test mail 1'; \
  sleep 0.1; echo ''; \
  sleep 0.1; echo 'Hello world user1!'; \
  sleep 0.1; echo '.'; \
  sleep 0.1; echo 'QUIT'; \
} | tee /dev/stderr | telnet plain.smtp.a.test 25