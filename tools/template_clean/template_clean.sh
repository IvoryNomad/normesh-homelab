#!/bin/bash

SCRIPT_DIR="/usr/local/share"
SCRIPT_NAME="template_clean"

if [ -n "${SUDO_USER}" ]; then
  echo "WARNING: Running with sudo prevents overwriting ${SUDO_USER}'s bash history file" 1>&2
  read -p "Continue? [y/N]" response
  if [[ ! "$response" =~ ^[yY]$ ]]; then
    echo "Aborting."
    exit 1
  fi
  CLOUD_USER=${CLOUD_USER:-cloud-user} HISTFILE=/dev/null /bin/bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
else
  history -w ~/.bash_history
  sudo CLOUD_USER=${CLOUD_USER:-cloud-user} HISTFILE=/dev/null /bin/bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
fi
