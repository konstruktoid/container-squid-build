FROM konstruktoid/alpine

RUN apk update && \
    apk upgrade && \
    apk --update add squid && \
    rm -rf /var/cache/apk/

COPY files/squid.conf /etc/squid/squid.conf

EXPOSE 3128

VOLUME ["/var/cache/squid"]
ENTRYPOINT ["/usr/sbin/squid"]
CMD ["-N"]
