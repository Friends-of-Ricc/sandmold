#!/bin/bash

set -euo pipefail
if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# Source the environment variables
source .env
if [ -f .env.post ]; then
    source .env.post
fi

# --- Configuration ---
UNIT_KIND_NAME="${UNIT_KIND_NAME_BASE}"
RELEASE_NAME="${RELEASE_NAME_BASE}"

echo "Repositioning Unit Kind '${UNIT_KIND_NAME}' default release to '${RELEASE_NAME}'..."

gcloud beta saas-runtime unit-kinds update "${UNIT_KIND_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --default-release="${RELEASE_NAME}" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "Unit Kind default release updated."

