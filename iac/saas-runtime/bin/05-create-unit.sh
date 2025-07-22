#!/bin/bash
#
# Creates a SaaS Unit (a VM instance) with a specified name and unit kind.
#

set -euo pipefail

# --- Argument Check ---
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Usage: $0 <instance-name> <unit-kind-name>"
    echo "  <instance-name>: The desired name for the new Compute Engine VM."
    echo "  <unit-kind-name>: The name of the Unit Kind to use (e.g., sandmold-sample-vm-global)."
    exit 1
fi

INSTANCE_NAME=$1
UNIT_KIND_TO_USE=$2

# Create a unique name for the SaaS Unit resource itself
SAAS_UNIT_NAME="unit-${INSTANCE_NAME}"

# --- Environment and Config ---
source .env

# Determine the SaaS Offering based on the Unit Kind's location
SAAS_OFFERING_GLOBAL="${SAAS_OFFERING_NAME}-global"
SAAS_OFFERING_REGIONAL="${SAAS_OFFERING_NAME}-regional"

# Determine the Unit Location based on the Unit Kind's name
UNIT_LOCATION="global"
if [[ "${UNIT_KIND_TO_USE}" == *"-regional"* ]]; then
    UNIT_LOCATION="${GOOGLE_CLOUD_REGION}"
fi

# --- Check and Create Unit ---
echo "Checking for Unit '${SAAS_UNIT_NAME}' in location '${UNIT_LOCATION}'..."

# Note: The 'describe' command for units requires the unit-kind and a location.
if ! gcloud beta saas-runtime units describe "${SAAS_UNIT_NAME}" \
    --unit-kind="${UNIT_KIND_TO_USE}" \
    --location="${UNIT_LOCATION}" \
    --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then

    echo "Creating Unit '${SAAS_UNIT_NAME}' to provision VM '${INSTANCE_NAME}' using Unit Kind '${UNIT_KIND_TO_USE}' in location '${UNIT_LOCATION}'..."
    gcloud beta saas-runtime units create "${SAAS_UNIT_NAME}" \
        --unit-kind="${UNIT_KIND_TO_USE}" \
        --location="${UNIT_LOCATION}" \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Unit '${SAAS_UNIT_NAME}' already exists in location '${UNIT_LOCATION}'."
fi

echo "Unit creation process for '${INSTANCE_NAME}' is complete."