FROM konstruktoid/alpine:latest@sha256:3f47343c0873bce996c9bd6d336b44e41faa77b86558a90e213eb8da644199de

LABEL org.opencontainers.image.title="squid" \
      org.opencontainers.image.description="Squid caching proxy" \
      org.opencontainers.image.authors="Thomas Sjögren <konstruktoid@users.noreply.github.com>" \
      org.opencontainers.image.source="https://github.com/konstruktoid/container-squid-build" \
      org.opencontainers.image.url="http://www.squid-cache.org/" \
      org.opencontainers.image.base.name="docker.io/konstruktoid/alpine"

COPY files/squid.conf /etc/squid/squid.conf

# --no-cache leaves no index behind, so there is no /var/cache/apk to remove.
RUN apk --no-cache add curl squid && \
    mkdir -p /run/squid && \
    chown -R squid:squid /etc/squid /var/cache/squid /run/squid && \
    chmod 0750 /var/cache/squid /run/squid

# The cache manager report is served through the proxy itself and is
# permitted by "http_access allow localhost manager".
HEALTHCHECK --interval=1m --timeout=3s --start-period=15s \
  CMD ["curl", "--fail", "--silent", "--show-error", "--proxy", "127.0.0.1:3128", "http://127.0.0.1:3128/squid-internal-mgr/info"]

EXPOSE 3128

VOLUME ["/var/cache/squid"]

USER squid

ENTRYPOINT ["/usr/sbin/squid"]
CMD ["--foreground"]
