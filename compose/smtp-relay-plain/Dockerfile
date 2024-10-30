FROM ubuntu:24.04

## package setup
RUN apt-get update && apt-get install -y \
    dnsutils iputils-ping vim iproute2 telnet mailutils

RUN apt-get install -y postfix



RUN rm -rf /var/lib/apt/lists/*



## postfix settings
RUN echo "smtp-relay-plain.test"  > /etc/mailname
RUN echo "nameserver 10.100.2.254" > /var/spool/postfix/etc/resolv.conf

#RUN rm -rf /etc/postfix/*
#COPY ./postfix /etc/postfix
COPY ./entrypoint.sh /

RUN sed -i -E "/(maillog_file|mail_spool_directory|home_mailbox|mynetworks|relayhost|myhostname|inet_protocols)/d" /etc/postfix/main.cf && \
    echo "\
maillog_file = /var/log/postfix\n\
mail_spool_directory = /var/mail/\n\
home_mailbox = Maildir/\n\
mynetworks = 127.0.0.0/8 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16\n\
relayhost = [mail-server.test]\n\
myhostname = smtp-relay-plain\n\
inet_protocols = ipv4" >> /etc/postfix/main.cf
RUN chmod +x /entrypoint.sh
EXPOSE 25/TCP
ENTRYPOINT ["/entrypoint.sh"]
