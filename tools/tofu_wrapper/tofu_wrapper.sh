#!/bin/bash

# wrapper script - run tofu with "op run"

# Print to stderr
echoerr() {
  echo "$@" 1>&2
}

SECRET_FILE="${SECRET_FILE:=$HOME/.secret.op}"
TOFU_ORIG="${TOFU_ORIG:-/usr/bin/tofu}"
ENV_FILE="${ENV_FILE:-.env}"

if [ ! -r "$SECRET_FILE" ]; then
  echoerr "ERROR (tofu_wrapper): secrets file not present"
  exit 1
fi

if [ ! -x "$TOFU_ORIG" ]; then
  echoerr "ERROR (tofu_wrapper): No executable tofu found"
  exit 1
fi

if [ ! -r "$ENV_FILE" ]; then
  echoerr "ERROR (tofu_wrapper): No environment file found"
  exit 1
fi

source "$SECRET_FILE"
op run --env-file="$ENV_FILE" -- "$TOFU_ORIG" "$@"
unset $(grep -v -E '^(#|export)' "$SECRET_FILE" | cut -d= -f1)
