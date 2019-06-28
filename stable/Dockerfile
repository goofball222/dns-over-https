FROM alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL \
    org.label-schema.vendor="The Goofball - goofball222@gmail.com" \
    org.label-schema.url="https://github.com/goofball222/dns-over-https" \
    org.label-schema.name="DNS over HTTPS Server/Client" \
    org.label-schema.version=$VERSION \
    org.label-schema.vcs-url="https://github.com/goofball222/dns-over-https.git" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.license="Apache-2.0" \
    org.label-schema.schema-version="1.0"

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
       gcc git go musl-dev \
    && apk add -q --no-cache \
        bash ca-certificates shadow su-exec tzdata \
    && go get github.com/m13253/dns-over-https/doh-server \
    && go get github.com/m13253/dns-over-https/doh-client \
    && cp -r /go/bin/* /usr/local/bin \
    && apk del -q --purge .build-deps \
    && rm -rf /go /root/.cache/* /tmp/* /var/cache/apk/*

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["doh-server"]
