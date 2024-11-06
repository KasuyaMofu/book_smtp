FROM kasuyamofu/smtpbook-dovecot:latest

ARG HOSTNAME DOMAIN FORWARD_TO

## postfix settings
RUN sed -i -E "/(myhostname|mydestination)/d" /etc/postfix/main.cf
RUN echo "${HOSTNAME}" >> /etc/mailname && \
    echo "myhostname = ${HOSTNAME}"         >> /etc/postfix/main.cf && \
    echo "mydestination = \$myhostname, ${DOMAIN}, plain.${DOMAIN}, spf.${DOMAIN}, dkim.${DOMAIN}, dmarc.${DOMAIN}, secure.${DOMAIN}" >> /etc/postfix/main.cf

RUN if [ -n "${FORWARD_TO}" ] ; then \
    touch /home/user2/.forward && chown user2: /home/user2/.forward && \
    echo '\user2' >> /home/user2/.forward && \
    echo '"|/usr/sbin/sendmail -f user2+forward@'"${DOMAIN}"' user2@'"${FORWARD_TO}"'"' >> /home/user2/.forward \
    ; fi

COPY ./example /example
COPY ./entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 143/TCP