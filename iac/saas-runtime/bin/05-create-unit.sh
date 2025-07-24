#!/bin/bash
#
# Creates a SaaS Unit (a VM instance) with a specified name.
#

set -euo pipefail
if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# --- Argument Check ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --instance-name)
            INSTANCE_NAME="$2"
            shift 2
            ;;
        --unit-kind-name)
            UNIT_KIND_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Create a unique name for the SaaS Unit resource itself
SAAS_UNIT_NAME="unit-${INSTANCE_NAME}"

source "$(dirname "$0")/common-setup.sh"

# --- Check and Create Unit ---
echo "Checking for Unit '${SAAS_UNIT_NAME}' in location '${GOOGLE_CLOUD_REGION}'..."

gcloud beta saas-runtime units create "${SAAS_UNIT_NAME}"     --unit-kind="${UNIT_KIND_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}" || echo "Unit '${SAAS_UNIT_NAME}' may already exist. Continuing..."

echo "Unit creation process for '${INSTANCE_NAME}' is complete."
