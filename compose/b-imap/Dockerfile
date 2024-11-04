FROM smtp-book-dovecot:latest

## user settings
RUN useradd -s /sbin/nologin -m user1 && \
    useradd -s /sbin/nologin -m user2 

RUN sed -i -e "/user[1-2]/d" /etc/shadow

RUN echo 'user1:$y$j9T$af58xeE18qixRYVn/7y7o/$Q3wjPYoDWUdQ.e5IVNJT5BZlSu2NL.MJ.HPPi5iS3K7:20018:0:99999:7:::' >> /etc/shadow && \
    echo 'user2:$y$j9T$e9.S8h1DEkvpQJhEnB1rv.$kvSz.rCOpvXHUFIAxvQA5y3qOsaPAPBUjKqw5H.jQmC:20018:0:99999:7:::' >> /etc/shadow

## postfix settings
RUN sed -i -E "/(myhostname|mydestination|home_mailbox)/d" /etc/postfix/main.cf
RUN echo "imap.b.test" >> /etc/mailname && \
    echo "home_mailbox = Maildir/" >> /etc/postfix/main.cf && \
    echo "myhostname = imap.b.test"         >> /etc/postfix/main.cf && \
    echo "mydestination = $myhostname, imap.b.test, b.test, plain.b.test, spf.b.test, dkim.b.test, dmarc.b.test, secure.b.test" >> /etc/postfix/main.cf

## dovecot settings
RUN sed -i -e "/mail_location/d" /etc/dovecot/dovecot.conf && \
    echo "mail_location = maildir:~/Maildir" >> /etc/dovecot/dovecot.conf && \
    echo "disable_plaintext_auth = no" >> /etc/dovecot/conf.d/10-auth.conf && \
    echo "listen = *" >> /etc/dovecot/dovecot.conf && \ 
    echo "protocols = imap" >> /etc/dovecot/dovecot.conf

EXPOSE 143/TCP

RUN echo "nameserver 10.100.2.254" > /var/spool/postfix/etc/resolv.conf

COPY ./entrypoint.sh /
COPY ./example /example

ENTRYPOINT ["/entrypoint.sh"]
