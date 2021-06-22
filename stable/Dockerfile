FROM alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL \
    org.opencontainers.image.vendor="The Goofball - goofball222@gmail.com" \
    org.opencontainers.image.url="https://github.com/goofball222/dns-over-https" \
    org.opencontainers.image.title="DNS over HTTPS Server/Client" \
    org.opencontainers.image.description="DNS over HTTPS Server/Client" \
    org.opencontainers.image.version=$VERSION \
    org.opencontainers.image.source="https://github.com/goofball222/dns-over-https" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.licenses="Apache-2.0"

ENV \
    DEBUG=false \
    GOPATH="/go" \
    GOCACHE="/tmp/gocache" \
    PGID=999 \
    PUID=999

WORKDIR /opt/dns-over-https

COPY root /

RUN \
    set -x \
    && delgroup ping \
    && addgroup -g $PGID doh \
    && adduser -D -G doh -u $PUID doh \
    && apk add -q --no-cache --virtual .build-deps \
       gcc git go make musl-dev \
    && apk add -q --no-cache \
        bash ca-certificates shadow su-exec tzdata \
    && bash -c 'mkdir -p {conf,data,src}' \
    && git clone https://github.com/m13253/dns-over-https.git /opt/dns-over-https/src \
    && cd /opt/dns-over-https/src/doh-client \
    && go build \
    && cp doh-client /usr/local/bin/doh-client \
    && chmod 0755 /usr/local/bin/doh-client \
    && cp doh-client.conf /opt/dns-over-https/data/doh-client.conf.default \
    && chmod 00644 /opt/dns-over-https/data/doh-client.conf.default \
    && cd /opt/dns-over-https/src/doh-server \
    && go build \
    && cp doh-server /usr/local/bin/doh-server \
    && chmod 0755 /usr/local/bin/doh-server \
    && cp doh-server.conf /opt/dns-over-https/data/doh-server.conf.default \
    && chmod 0644 /opt/dns-over-https/data/doh-server.conf.default \
    && cd /opt/dns-over-https \
    && apk del -q --purge .build-deps \
    && rm -rf /go /opt/dns-over-https/src /root/.cache/* /tmp/* /var/cache/apk/* \
    && chown -R doh:doh /opt/dns-over-https

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["doh-server"]
