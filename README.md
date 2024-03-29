# DNS-over-HTTPS Docker Container

[![Latest Build Status](https://github.com/goofball222/dns-over-https/actions/workflows/build-latest.yml/badge.svg)](https://github.com/goofball222/dns-over-https/actions/workflows/build-latest.yml) [![Docker Pulls](https://img.shields.io/docker/pulls/goofball222/dns-over-https.svg)](https://hub.docker.com/r/goofball222/dns-over-https/) [![Docker Stars](https://img.shields.io/docker/stars/goofball222/dns-over-https.svg)](https://hub.docker.com/r/goofball222/dns-over-https/) [![License](https://img.shields.io/github/license/goofball222/dns-over-https.svg)](https://github.com/goofball222/dns-over-https)

## Docker tags:
| Tag | dns-over-https Version | Description | Release Date |
| --- | :---: | --- | :---: |
| [latest](https://github.com/goofball222/dns-over-https/blob/main/stable/Dockerfile) | 2.3.3 | Latest stable release | 2023-09-22 |

---

* [Recent changes, see: GitHub CHANGELOG.md](https://github.com/goofball222/dns-over-https/blob/main/CHANGELOG.md)
* [Report any bugs, issues or feature requests on GitHub](https://github.com/goofball222/dns-over-https/issues)

---

## Description

DNS-over-HTTPS container built on Alpine Linux. Recommended to run behind Traefik or other proxy.

---

## Usage

---

**Basic docker-compose.yml to launch DNS-over-HTTPS server with labels for Traefik.**

```bash

version: '3'

services:
  dns-over-https:
    image: goofball222/dns-over-https
    container_name: dns-over-https
    restart: unless-stopped
    networks:
      external:
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./dohconf/:/opt/dns-over-https/conf/
    environment:
      - TZ=UTC
    labels:
      - traefik.backend=securedns
      - traefik.frontend.rule=Host:securedns.domain.name
      - traefik.port=8053
      - traefik.docker.network=proxy
      - traefik.enable=true

networks:
  external:
    external:
      name: proxy

```

---

**Basic docker-compose.yml to launch DNS-over-HTTPS client mode**

```bash

version: '3'

services:
  dns-over-https-client:
    image: goofball222/dns-over-https
    container_name: dns-over-https
    restart: unless-stopped
    networks:
      external:
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./dohconf/:/opt/dns-over-https/conf/
    environment:
      - TZ=UTC
    labels:
      - traefik.backend=securedns
      - traefik.frontend.rule=Host:securedns.domain.name
      - traefik.port=8053
      - traefik.docker.network=proxy
      - traefik.enable=true
    command: ["doh-client"]

networks:
  external:
    external:
      name: proxy

```

---

**Extended docker-compose.yml to launch DNS-over-HTTPS server with Traefik labels attached to Unbound DNS server backend**

```bash

version: '3'

services:
  unbound:
    image: mvance/unbound
    container_name: unbound
    restart: unless-stopped
    networks:
      external:
    ports:
      - 853:853/tcp
      - 853:853/udp
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /etc/ssl/certs/ca-certificates.crt:/etc/ssl/certs/ca-certificates.crt:ro
      - ./unbound:/opt/unbound/etc/unbound
      - /etc/letsencrypt/live/securedns.domain.name/fullchain.pem:/etc/ssl/certs/cert.pem:ro
      - /etc/letsencrypt/live/securedns.domain.name/privkey.pem:/etc/ssl/certs/key.pem:ro
    environment:
      - TZ=UTC

  dns-over-https:
    image: goofball222/dns-over-https
    container_name: dns-over-https
    restart: unless-stopped
    networks:
      external:
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./doh-conf:/opt/dns-over-https/conf
    environment:
      - TZ=UTC
    labels:
      - traefik.backend=securedns
      - traefik.frontend.rule=Host:securedns.domain.name
      - traefik.port=8053
      - traefik.docker.network=proxy
      - traefik.enable=true

networks:
  external:
    external:
      name: proxy

```

---

**Environment variables:**

| Variable | Default | Description |
| :--- | :---: | --- |
| `DEBUG` | ***false*** | Set to *true* for extra entrypoint script verbosity for debugging |
| `PGID` | ***999*** | Specifies the GID for the container internal process group (used for file ownership) |
| `PUID` | ***999*** | Specifies the UID for the container internal process user (used for process and file ownership) |

**DNS-over-HTTPS configuration examples:**

[DNS-over-HTTPS server example config](https://github.com/goofball222/dns-over-https/blob/main/examples/doh-server.conf)

[DNS-over-HTTPS client example config](https://github.com/goofball222/dns-over-https/blob/main/examples/doh-client.conf)

[//]: # (Licensed under the Apache 2.0 license)
[//]: # (Copyright 2018 The Goofball - goofball222@gmail.com)
