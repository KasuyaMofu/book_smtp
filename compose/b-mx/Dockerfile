FROM smtp-book-postfix:latest

## postfix settings
RUN echo "mx.b.test"  > /etc/mailname
RUN echo "nameserver 10.100.2.254" > /var/spool/postfix/etc/resolv.conf

RUN sed -i -E "/myhostname/d" /etc/postfix/main.cf && \
    echo "myhostname = mx.b.test" >> /etc/postfix/main.cf

RUN sed -i -E "/relayhost/d" /etc/postfix/main.cf && \
echo "\
relayhost = [imap.b.test]" >> /etc/postfix/main.cf

COPY ./entrypoint.sh /

EXPOSE 25/TCP
ENTRYPOINT ["/entrypoint.sh"]
