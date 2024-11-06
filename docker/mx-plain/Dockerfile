FROM kasuyamofu/smtpbook-postfix:latest

ARG HOSTNAME RELAYHOST

## postfix settings
RUN echo "${HOSTNAME}"  > /etc/mailname

RUN sed -i -E "/(myhostname|relayhost)/d" /etc/postfix/main.cf && \
    echo "myhostname = ${HOSTNAME}" >> /etc/postfix/main.cf && \
    echo "relayhost = ${RELAYHOST}" >> /etc/postfix/main.cf

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 25/TCP
