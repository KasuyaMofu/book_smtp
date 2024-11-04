FROM smtp-book-smtp-dkim:latest

RUN bash -c "rm /etc/rspamd/modules.d/{rbl.conf,spf.conf,surbl.conf,whitelist.conf,mid.conf,known_senders.conf,phishing.conf,mime_types.conf}"

COPY ./entrypoint.sh /
COPY ./rspamd/key/*     /var/lib/rspamd/dkim/
COPY ./rspamd/local.d/* /etc/rspamd/local.d/

RUN echo "smtpd_milters = inet:localhost:11332" >> /etc/postfix/main.cf && \
    echo "non_smtpd_milters = inet:localhost:11332" >> /etc/postfix/main.cf && \
    echo "milter_protocol = 6" >> /etc/postfix/main.cf && \
    echo "milter_default_action = accept"

RUN echo "dkim.smtp.a.test"  > /etc/mailname
RUN echo "nameserver 10.100.2.254" > /var/spool/postfix/etc/resolv.conf

RUN sed -i -E "/myhostname/d" /etc/postfix/main.cf && \
    echo "myhostname = dkim.smtp.a.test" >> /etc/postfix/main.cf

ENTRYPOINT ["/entrypoint.sh"]