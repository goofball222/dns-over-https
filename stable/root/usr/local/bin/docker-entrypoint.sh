#!/usr/bin/env bash

# Init script for DNS over HTTPS proxy Docker container
# License: Apache-2.0
# Github: https://github.com/goofball222/dns-over-https.git
SCRIPT_VERSION="1.2.0"
# Last updated date: 2021-06-21

set -Eeuo pipefail

if [ "${DEBUG}" == 'true' ]; then
    set -x
fi

. /usr/local/bin/entrypoint-functions.sh

BASEDIR="/opt/dns-over-https"
CONFDIR=${BASEDIR}/conf
DATADIR=${BASEDIR}/data

f_log "INFO - Entrypoint script version ${SCRIPT_VERSION}"
f_log "INFO - Entrypoint functions version ${ENTRYPOINT_FUNCTIONS_VERSION}"

cd ${BASEDIR}

RUNPROC=$(which ${@})

f_exit_handler() {
    f_log "INFO - Exit signal received, commencing shutdown"
    pkill -15 -f ${RUNPROC}
    for i in `seq 0 10`;
        do
            [ -z "$(pgrep -f ${RUNPROC})" ] && break
            # kill it with fire if it hasn't stopped itself after 20 seconds
            [ $i -gt 9 ] && pkill -9 -f ${RUNPROC} || true
            sleep 1
    done
    f_log "INFO - Shutdown complete. Nothing more to see here. Have a nice day!"
    f_log "INFO - Exit with status code ${?}"
    exit ${?};
}

f_idle_handler() {
    while true
    do
        tail -f /dev/null & wait ${!}
    done
}

trap 'kill ${!}; f_exit_handler' SIGHUP SIGINT SIGQUIT SIGTERM

if [ "$(id -u)" = '0' ]; then
    f_log "INFO - Entrypoint running with UID 0 (root)"
    if [[ "${@}" =~ 'doh-' ]]; then
        f_confchk
        f_giduid

        f_log "INFO - Use su-exec to drop privileges and start process as GID=${PGID}, UID=${PUID}"
        f_log "EXEC - su-exec doh:doh ${@} -conf ${CONFFILE}"
        exec su-exec doh:doh ${@} -conf ${CONFFILE} &
        f_idle_handler
    else
        f_log "EXEC - ${@} as UID 0 (root)"
        exec "${@}"
    fi
else
    f_log "WARN - Container/entrypoint not started as UID 0 (root)"
    f_log "WARN - Unable to change permissions or set custom GID/UID if configured"
    f_log "WARN - Process will be spawned with GID=$(id -g), UID=$(id -u)"
    f_log "WARN - Depending on permissions requested command may not work"
    if [[ "${@}" =~ 'doh-' ]]; then
        f_confchk
        f_log "EXEC - ${@} -conf ${CONFFILE}"
        exec ${@} -conf ${CONFFILE} &
        f_idle_handler
    else
        f_log "EXEC - ${@}"
        exec "${@}"
    fi
fi

# Script should never make it here, but just in case exit with a generic error code if it does
exit 1;
