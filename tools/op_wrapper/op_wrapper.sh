#!/bin/bash

# wrapper script for 1Password CLI 'op' command

SECRET_FILE=~/.secret.op
if [ ! -f "$SECRET_FILE" ]; then
  echo "ERROR: secrets file not present"
  exit 1
fi
source "$SECRET_FILE"
op "$@"
unset $(grep -v -E '^(#|export)' "$SECRET_FILE" | cut -d= -f1)
