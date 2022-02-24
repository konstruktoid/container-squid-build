# Squid

_Please note that because of the changes to [Docker Automated Builds](https://docs.docker.com/docker-hub/builds/)
many Docker images are now outdated and a manual build is required and recommended._

```sh
"Squid is a caching proxy for the Web supporting HTTP, HTTPS, FTP, and more.
It reduces bandwidth and improves response times by caching and reusing
frequently-requested web pages. Squid has extensive access controls and makes a
great server accelerator. It runs on most available operating systems, including
Windows and is licensed under the GNU GPL."
```

[http://www.squid-cache.org](http://www.squid-cache.org/)

```sh
docker build --no-cache --tag konstruktoid/squid -f Dockerfile .
docker run  --cap-drop=all --cap-add={setgid,setuid} -d -p3128:3128 konstruktoid/squid
curl --proxy 127.0.0.1:3128 --head https://duckduckgo.com
```
