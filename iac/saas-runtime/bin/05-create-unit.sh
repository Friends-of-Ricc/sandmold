#!/bin/bash
#
# Creates a SaaS Unit (a VM instance) using the default parameters from the Release.
#

set -euo pipefail

# --- Argument Check ---
if [ -z "$1" ]; then
    echo "Usage: $0 <unit-name>"
    echo "  <unit-name>: The desired name for the SaaS Unit resource."
    exit 1
fi

SAAS_UNIT_NAME=$1

# --- Environment and Config ---
source .env

# --- Check and Create Unit ---
echo "Checking for Unit '${SAAS_UNIT_NAME}'..."

# Note: The 'describe' command for units requires the unit-kind and a location.
if ! gcloud beta saas-runtime units describe "${SAAS_UNIT_NAME}" \
    --unit-kind="${UNIT_KIND_NAME_GLOBAL}" \
    --location=global \
    --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then

    echo "Creating Unit '${SAAS_UNIT_NAME}' using Unit Kind '${UNIT_KIND_NAME_GLOBAL}'..."
    gcloud beta saas-runtime units create "${SAAS_UNIT_NAME}" \
        --unit-kind="${UNIT_KIND_NAME_GLOBAL}" \
        --location=global \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Unit '${SAAS_UNIT_NAME}' already exists."
fi

echo "Unit creation process for '${SAAS_UNIT_NAME}' is complete."
