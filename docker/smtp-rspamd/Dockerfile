FROM kasuyamofu/smtpbook-rspamd:latest

ARG HOSTNAME

## postfix settings
RUN echo "${HOSTNAME}"  > /etc/mailname && \
    sed -i -E "/myhostname/d" /etc/postfix/main.cf && \
    echo "myhostname = ${HOSTNAME}" >> /etc/postfix/main.cf

## Rspamd settings
RUN rm /etc/rspamd/override.d/dkim_signing.conf
COPY ./rspamd/key/*     /var/lib/rspamd/dkim/
COPY ./rspamd/local.d/* /etc/rspamd/local.d/
COPY ./rspamd/override.d/* /etc/rspamd/override.d/

RUN chown -R rspamd:rspamd /var/lib/rspamd/ /etc/rspamd/ /var/log/rspamd/

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]