FROM konstruktoid/alpine:latest@sha256:3a1ce60835cb22f26e58e8a1c06fdb77a9acda710c5f9d343b1c35b62d2a6c6f

LABEL org.opencontainers.image.title="squid" \
      org.opencontainers.image.description="Squid caching proxy" \
      org.opencontainers.image.authors="Thomas Sjögren <konstruktoid@users.noreply.github.com>" \
      org.opencontainers.image.source="https://github.com/konstruktoid/container-squid-build" \
      org.opencontainers.image.url="https://www.squid-cache.org/" \
      org.opencontainers.image.base.name="docker.io/konstruktoid/alpine"

COPY files/squid.conf /etc/squid/squid.conf

# --no-cache leaves no index behind, so there is no /var/cache/apk to remove.
# The packages are deliberately unpinned: the image exists to carry the newest
# patched package set. See "Reproducibility" in README.md.
# hadolint ignore=DL3018
RUN apk --no-cache add curl squid && \
    mkdir -p /run/squid && \
    chown -R squid:squid /etc/squid /var/cache/squid /run/squid && \
    chmod 0750 /var/cache/squid /run/squid

# The cache manager report is served through the proxy itself and is
# permitted by "http_access allow localhost manager". --noproxy "" keeps a
# NO_PROXY value inherited from the environment from bypassing --proxy, which
# would make the check pass without ever going through Squid.
HEALTHCHECK --interval=1m --timeout=3s --start-period=15s \
  CMD ["curl", "--fail", "--silent", "--show-error", "--noproxy", "", "--proxy", "127.0.0.1:3128", "http://127.0.0.1:3128/squid-internal-mgr/info"]

EXPOSE 3128

VOLUME ["/var/cache/squid"]

# squid, uid 31, gid 31, created by the Alpine package.
USER squid

ENTRYPOINT ["/usr/sbin/squid"]
CMD ["--foreground"]
