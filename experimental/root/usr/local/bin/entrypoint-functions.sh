#!/usr/bin/env bash

# entrypoint-functions.sh script for UniFi Docker container
# License: Apache-2.0
# Github: https://github.com/goofball222/dns-over-https
ENTRYPOINT_FUNCTIONS_VERSION="1.0.0"
# Last updated date: 2018-11-12

f_confchk() {
    cp ${DATADIR}/doh-client.conf.default ${CONFDIR}/doh-client.conf.default
    cp ${DATADIR}/doh-server.conf.default ${CONFDIR}/doh-server.conf.default

    if [ ! -f "${CONFDIR}/doh-client.conf" ]; then
        cp ${DATADIR}/doh-client.conf.default ${CONFDIR}/doh-client.conf
    fi

    if [ ! -f "${CONFDIR}/doh-server.conf" ]; then
        cp ${DATADIR}/doh-server.conf.default ${CONFDIR}/doh-server.conf
    fi

    if [ "${RUNPROC}" == '/usr/local/bin/doh-client' ]; then
        CONFFILE="/opt/dns-over-https/conf/doh-client.conf"
    elif [ "${RUNPROC}" == '/usr/local/bin/doh-server' ]; then
        CONFFILE="/opt/dns-over-https/conf/doh-server.conf"
    else
        f_log "ERROR - ${@} NOT A VALID OPTION. Run state is invalid. Exiting."
        exit 1;
    fi
}

f_giduid() {
    if [ "$(id doh -g)" != "${PGID}" ] || [ "$(id doh -u)" != "${PUID}" ]; then
        f_log "INFO - Setting custom doh GID/UID: GID=${PGID}, UID=${PUID}"
        groupmod -o -g ${PGID} doh
        usermod -o -u ${PUID} doh
    else
        f_log "INFO - GID/UID for doh are unchanged: GID=${PGID}, UID=${PUID}"
    fi

    chown -R doh:doh /opt/dns-over-https/
}

f_log() {
    echo "$(date +"[%Y-%m-%d %T,%3N]") <docker-entrypoint> $*"
}

