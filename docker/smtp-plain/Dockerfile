FROM kasuyamofu/smtpbook-postfix:latest

ARG HOSTNAME

## postfix settings
RUN echo "${HOSTNAME}"  > /etc/mailname && \
    sed -i -E "/myhostname/d" /etc/postfix/main.cf && \
    echo "myhostname = ${HOSTNAME}" >> /etc/postfix/main.cf

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 25/TCP
