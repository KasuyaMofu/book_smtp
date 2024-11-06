FROM kasuyamofu/smtpbook-unbound:latest

COPY unbound/unbound.conf.d/* /etc/unbound/unbound.conf.d/

RUN unbound-checkconf

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 53/TCP 53/UDP