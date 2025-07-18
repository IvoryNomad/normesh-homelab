#!/bin/bash

# wrapper script for 1Password CLI 'op' command

# Print to stderr
echoerr() {
  echo "$@" 1>&2
}

SECRET_FILE="${SECRET_FILE:=$HOME/.secret.op}"
if [ ! -r "$SECRET_FILE" ]; then
  echoerr "ERROR (op_wrapper): secrets file not present"
  exit 1
fi
source "$SECRET_FILE"
op "$@"
unset $(grep -v -E '^(#|export)' "$SECRET_FILE" | cut -d= -f1)
