#!/bin/bash
#
# Creates a SaaS Unit (a VM instance) with a specified name.
#

set -euo pipefail
if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# --- Argument Check ---
if [ -z "$1" ]; then
    echo "Usage: $0 <instance-name>"
    echo "  <instance-name>: The desired name for the new Compute Engine VM."
    exit 1
fi

INSTANCE_NAME=$1

# Create a unique name for the SaaS Unit resource itself
SAAS_UNIT_NAME="unit-${INSTANCE_NAME}"

# --- Environment and Config ---
source .env

# --- Check and Create Unit ---
echo "Checking for Unit '${SAAS_UNIT_NAME}' in location '${GOOGLE_CLOUD_REGION}'..."

gcloud beta saas-runtime units create "${SAAS_UNIT_NAME}" \
    --unit-kind="${UNIT_KIND_NAME_BASE}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}" || echo "Unit '${SAAS_UNIT_NAME}' may already exist. Continuing..."

echo "Unit creation process for '${INSTANCE_NAME}' is complete."
