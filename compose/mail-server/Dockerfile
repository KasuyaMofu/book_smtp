FROM ubuntu:24.04

## package setup
RUN apt-get update && apt-get install -y \
    dnsutils iputils-ping vim iproute2 telnet mailutils

RUN apt-get install -y postfix 

RUN apt-get install -y dovecot-core dovecot-imapd

RUN rm -rf /var/lib/apt/lists/*

## user settings for 

RUN useradd -s /sbin/nologin -m user1 && \
    useradd -s /sbin/nologin -m user2 

RUN sed -i -e "/user[1-2]/d" /etc/shadow

RUN echo 'user1:$y$j9T$af58xeE18qixRYVn/7y7o/$Q3wjPYoDWUdQ.e5IVNJT5BZlSu2NL.MJ.HPPi5iS3K7:20018:0:99999:7:::' >> /etc/shadow && \
    echo 'user2:$y$j9T$e9.S8h1DEkvpQJhEnB1rv.$kvSz.rCOpvXHUFIAxvQA5y3qOsaPAPBUjKqw5H.jQmC:20018:0:99999:7:::' >> /etc/shadow

## postfix settings

RUN sed -i -e "/mynetworks/d" -e "/myhostname/d" /etc/postfix/main.cf
RUN echo "mail-server.test" >> /etc/mailname && \
    echo "maillog_file = /var/log/postfix" >> /etc/postfix/main.cf && \
    echo "mail_spool_directory = /var/mail/" >> /etc/postfix/main.cf && \
    echo "home_mailbox = Maildir/" >> /etc/postfix/main.cf && \
    echo "mynetworks = 127.0.0.0/8 10.100.2.0/24 10.100.4.0/24" >> /etc/postfix/main.cf && \
    echo "myhostname = mail-server"         >> /etc/postfix/main.cf && \
    echo "mydestination = $myhostname, mail-server.test" >> /etc/postfix/main.cf

## dovecot settings
RUN sed -i -e "/mail_location/d" /etc/dovecot/dovecot.conf && \
    echo "mail_location = maildir:~/Maildir" >> /etc/dovecot/dovecot.conf && \
    echo "disable_plaintext_auth = no" >> /etc/dovecot/conf.d/10-auth.conf && \
    echo "listen = *" >> /etc/dovecot/dovecot.conf && \ 
    echo "protocols = imap" >> /etc/dovecot/dovecot.conf

EXPOSE 143/TCP

RUN echo "nameserver 10.100.2.254" > /var/spool/postfix/etc/resolv.conf

COPY ./entrypoint.sh /
COPY ./example /example
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
