FROM smtp-book-mx-spf-dkim:latest

COPY ./rspamd/local.d/* /etc/rspamd/local.d/
COPY ./rspamd/override.d/* /etc/rspamd/override.d/

RUN echo "smtpd_milters = inet:localhost:11332" >> /etc/postfix/main.cf && \
    echo "non_smtpd_milters = inet:localhost:11332" >> /etc/postfix/main.cf && \
    echo "milter_protocol = 6" >> /etc/postfix/main.cf && \
    echo "milter_default_action = accept"

## postfix settings
RUN echo "spf-mx.b.test"  > /etc/mailname
RUN echo "nameserver 10.100.2.254" > /var/spool/postfix/etc/resolv.conf

RUN sed -i -E "/myhostname/d" /etc/postfix/main.cf && \
    echo "myhostname = spf-mx.b.test" >> /etc/postfix/main.cf
RUN sed -i -E "/relayhost/d" /etc/postfix/main.cf && \
echo "\
relayhost = [imap.b.test]" >> /etc/postfix/main.cf

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]