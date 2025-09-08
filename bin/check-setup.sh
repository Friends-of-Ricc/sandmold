#!/bin/bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

. .env

if [ "$(gcloud config get-value account)" != "$GCLOUD_IDENTITY" ]; then
  echo "gcloud is not authenticated as $GCLOUD_IDENTITY"
  echo "Please run 'just setup-gcloud' to authenticate."
  exit 1
fi
