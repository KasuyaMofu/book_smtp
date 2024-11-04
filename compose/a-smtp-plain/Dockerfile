FROM smtp-book-postfix:latest

## postfix settings
RUN echo "plain.smtp.a.test"  > /etc/mailname
RUN echo "nameserver 10.100.2.254" > /var/spool/postfix/etc/resolv.conf

RUN sed -i -E "/myhostname/d" /etc/postfix/main.cf && \
    echo "myhostname = plain.smtp.a.test" >> /etc/postfix/main.cf

RUN sed -i -E "/(relayhost|transport_maps)/d" /etc/postfix/main.cf && \
    echo "\
transport_maps = hash:/etc/postfix/transport" >> /etc/postfix/main.cf

# postfix transport settings
RUN echo "\
b.test           smtp:b.test\n\
spf.b.test       smtp:spf.b.test\n\
imap.b.test      smtp:imap.b.test\n\
secure.imap.test smtp:secure.imap.test" > /etc/postfix/transport 

COPY ./entrypoint.sh /

EXPOSE 25/TCP
ENTRYPOINT ["/entrypoint.sh"]
