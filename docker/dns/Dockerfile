FROM kasuyamofu/smtpbook-unbound:latest

COPY unbound/unbound.conf.d/* /etc/unbound/unbound.conf.d/

ARG NETWORK
RUN sed -i "s/_NETWORK/${NETWORK}/" /etc/unbound/unbound.conf.d/*.conf

RUN unbound-checkconf

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 53/TCP 53/UDP
