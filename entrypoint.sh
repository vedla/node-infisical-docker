#!/bin/sh
set -eu

: "${INFISICAL_DOMAIN:?INFISICAL_DOMAIN is required}"
: "${INFISICAL_CLIENT_ID:?INFISICAL_CLIENT_ID is required}"
: "${INFISICAL_CLIENT_SECRET:?INFISICAL_CLIENT_SECRET is required}"

if ! INFISICAL_TOKEN="$(
  infisical login \
    --method=universal-auth \
    --client-id="$INFISICAL_CLIENT_ID" \
    --client-secret="$INFISICAL_CLIENT_SECRET" \
    --plain \
    --silent \
    --domain="$INFISICAL_DOMAIN"
)" || [ -z "$INFISICAL_TOKEN" ]; then
  echo "[ERROR] Failed to authenticate with Infisical." >&2
  exit 1
fi

export INFISICAL_TOKEN
echo "[SUCCESS] Authenticated with Infisical."
exec "$@"
