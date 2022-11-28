#!/usr/bin/env bash

[ -n "${MYUID}" ] && usermod -u "${MYUID}" "${USER}"
[ -n "${MYGID}" ] && groupmod -g "${MYGID}" "${USER}"

if [ -n "${MYUID}" ] || [ -n "${MYGID}" ]; then
    echo "Setting file ownership..."
    chown -R --silent "${USER}:${USER}" "${APP_DIR}"
fi

exec gosu "$USER" bash -c "$@"
