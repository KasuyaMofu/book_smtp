FROM kasuyamofu/smtpbook-rspamd:latest

## Rspamd settings
RUN rm /etc/rspamd/override.d/dkim_signing.conf
COPY ./rspamd/key/*     /var/lib/rspamd/dkim/
COPY ./rspamd/local.d/* /etc/rspamd/local.d/
COPY ./rspamd/override.d/* /etc/rspamd/override.d/

ARG HOSTNAME NETWORK

## postfix settings
RUN echo "${HOSTNAME}"  > /etc/mailname && \
    sed -i -E "/myhostname/d" /etc/postfix/main.cf && \
    echo "myhostname = ${HOSTNAME}" >> /etc/postfix/main.cf
RUN sed -i "s/_NETWORK/${NETWORK}/" /etc/rspamd/override.d/options.inc

RUN chown -R rspamd:rspamd /var/lib/rspamd/ /etc/rspamd/ /var/log/rspamd/


COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
