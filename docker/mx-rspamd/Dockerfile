FROM kasuyamofu/smtpbook-rspamd:latest

ARG HOSTNAME RELAYHOST ROLE

## postfix settings
RUN echo "${HOSTNAME}"  > /etc/mailname

RUN sed -i -E "/(myhostname|relayhost)/d" /etc/postfix/main.cf && \
    echo "myhostname = ${HOSTNAME}" >> /etc/postfix/main.cf && \
    echo "relayhost = ${RELAYHOST}" >> /etc/postfix/main.cf

RUN rm /etc/rspamd/override.d/milter_headers.conf
RUN case "${ROLE}" in \ 
        spf)    rm /etc/rspamd/override.d/spf.conf ;;  \
        dkim)   rm /etc/rspamd/override.d/dkim.conf ;; \
        dmarc)  bash -c "rm /etc/rspamd/override.d/{spf.conf,dkim.conf,dmarc.conf}"  ;; \
        *)      echo "ROLE is not set" ;; \
    esac

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]