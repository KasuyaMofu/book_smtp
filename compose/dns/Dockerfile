FROM ubuntu:24.04

## package setup
RUN apt-get update && apt-get install -y \
    dnsutils iputils-ping vim iproute2 telnet mailutils

RUN apt-get install -y unbound unbound-anchor 



RUN rm -rf /var/lib/apt/lists/*

RUN rm /etc/unbound/unbound.conf.d/*
RUN unbound-anchor -4 -a "/etc/unbound/root.key" ; ls -al /etc/unbound/root.key

COPY unbound/unbound.conf /etc/unbound/unbound.conf
COPY unbound/unbound.conf.d/* /etc/unbound/unbound.conf.d/

RUN chown -R unbound:unbound /etc/unbound

RUN unbound-checkconf

EXPOSE 53/TCP 53/UDP

ENTRYPOINT ["unbound-control","start"]