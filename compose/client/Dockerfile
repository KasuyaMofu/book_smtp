FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    ca-certificates dnsutils iputils-ping vim iproute2 telnet mailutils

RUN rm -rf /var/lib/apt/lists/*


COPY ./example /example
ENTRYPOINT ["sleep","infinity"]