FROM smtp-book-unbound:latest

RUN rm /etc/unbound/unbound.conf.d/*
RUN unbound-anchor -4 -a "/etc/unbound/root.key" ; ls -al /etc/unbound/root.key

COPY unbound/unbound.conf /etc/unbound/unbound.conf
COPY unbound/unbound.conf.d/* /etc/unbound/unbound.conf.d/
COPY ./entrypoint.sh /

RUN mkdir -p /etc/unbound/var/log
RUN touch /etc/unbound/var/log/unbound.log
RUN chown -R unbound:unbound /etc/unbound

RUN unbound-checkconf

EXPOSE 53/TCP 53/UDP

ENTRYPOINT ["/entrypoint.sh"]