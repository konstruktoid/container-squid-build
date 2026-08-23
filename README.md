# Squid

```text
"Squid is a caching proxy for the Web supporting HTTP, HTTPS, FTP, and more.
It reduces bandwidth and improves response times by caching and reusing
frequently-requested web pages. Squid has extensive access controls and makes a
great server accelerator. It runs on most available operating systems, including
Windows and is licensed under the GNU GPL."
```

[https://www.squid-cache.org](https://www.squid-cache.org/)

## Build and run

The image runs as the unprivileged `squid` user, uid 31 and gid 31 as created
by the Alpine `squid` package, and listens on 3128, so it needs no added
capabilities.

```sh
docker build --no-cache --tag konstruktoid/squid -f Dockerfile .
docker run --cap-drop=all --dns 1.1.1.2 -d -p 3128:3128 konstruktoid/squid
curl --proxy 127.0.0.1:3128 --head https://duckduckgo.com
```

`/var/cache/squid` is a volume; `coredump_dir` points at it and it is where a
`cache_dir` would live if you enable one.

## Health check

The `HEALTHCHECK` fetches the cache manager report through the proxy itself,
from inside the container:

```sh
docker exec <container> \
  curl --fail --noproxy "" --proxy 127.0.0.1:3128 \
    http://127.0.0.1:3128/squid-internal-mgr/info
```

`--noproxy ""` empties curl's no-proxy list. Without it a `NO_PROXY` value
inherited from the environment can match `127.0.0.1`, and curl would then
ignore `--proxy` and answer from the URL directly, so the check would pass
without Squid being involved at all.

`http_access allow localhost manager` is matched before the loopback denial
below, so the report stays reachable while ordinary loopback requests do not.
The report is only served to `localhost`, so the same request made from the
host through the published port is denied with a 403.

## Configuration

`files/squid.conf` allows the RFC 1918/6598 private ranges and localhost, and
denies everything else. It also:

* disables access logging (`access_log none`, `cache_log /dev/null`);
* strips the `Via` and `X-Forwarded-For` headers, along with `From`, `Server`,
  `WWW-Authenticate`, `Link`, `Cache-Control`, `Proxy-Connection`, `X-Cache`,
  `X-Cache-Lookup`, `Pragma` and `Keep-Alive`;
* enables `http_access deny to_localhost` and `http_access deny to_linklocal`,
  so the proxy cannot be used to reach services bound to loopback on the proxy
  host, nor cloud instance metadata on `169.254.169.254` or anything else on
  `169.254.0.0/16` and `fe80::/10`;
* sets `pid_filename /run/squid/squid.pid`, because `/var/run` is not writable
  by the unprivileged user the image runs as.

## Reproducibility

The base image is pinned by digest, so `FROM` always resolves to the same
layers. The Alpine packages installed on top of it are deliberately *not*
version pinned: the image exists to carry the newest patched `squid` and
`curl`. Two builds a week apart will therefore contain different package
versions and produce different image digests.

Dependabot moves the base image digest forward; nothing freezes the packages.
If you need a fixed set, build once and refer to the result by digest instead
of by tag.

## Development

`.pre-commit-config.yaml` runs gitleaks, hadolint, actionlint and
markdownlint:

```sh
pre-commit run --all-files
```
