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
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --unit-kind-name)
            UNIT_KIND_NAME="$2"
            shift 2
            ;;
        --release-name)
            RELEASE_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "Repositioning Unit Kind '${UNIT_KIND_NAME}' default release to '${RELEASE_NAME}'..."

gcloud beta saas-runtime unit-kinds update "${UNIT_KIND_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --default-release="${RELEASE_NAME}" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "Unit Kind default release updated."

