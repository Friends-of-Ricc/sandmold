#!/bin/bash
#
# Triggers provisioning for a specific SaaS Unit.
#

set -euo pipefail

# --- Argument Check ---
if [ -z "$1" ]; then
    echo "Usage: $0 <unit-name>"
    echo "  <unit-name>: The name of the SaaS Unit to provision (e.g., unit-my-vm)."
    exit 1
fi

UNIT_NAME=$1

# --- Environment and Config ---
source .env

TENANT_PROJECT_ID="${GOOGLE_CLOUD_PROJECT}"
TENANT_PROJECT_NUMBER=$(gcloud projects describe "${TENANT_PROJECT_ID}" --format="value(projectNumber)")
ACTUATION_SA="${TENANT_PROJECT_NUMBER}-compute@developer.gserviceaccount.com"

# Determine the Unit Kind and location based on the unit name
UNIT_KIND_TO_USE="${UNIT_KIND_NAME_BASE}-global"
UNIT_LOCATION="${GOOGLE_CLOUD_REGION}"
if [[ "${UNIT_NAME}" == *"regional"* ]]; then
    UNIT_KIND_TO_USE="${UNIT_KIND_NAME_BASE}-regional"
    UNIT_LOCATION="${GOOGLE_CLOUD_REGION}"
fi

# Construct the full Unit resource name
UNIT_RESOURCE_NAME="projects/${GOOGLE_CLOUD_PROJECT}/locations/${GOOGLE_CLOUD_REGION}/units/${UNIT_NAME}"

# --- Trigger Provisioning Unit Operation ---
echo "Triggering provisioning for Unit '${UNIT_NAME}' using Unit Kind '${UNIT_KIND_TO_USE}'..."
gcloud --log-http beta saas-runtime unit-operations create "provision-${UNIT_NAME}-$(date +%s)" \
    --unit="${UNIT_RESOURCE_NAME}" \
    --provision \
    --provision-release="${RELEASE_NAME}" \
    --provision-input-variables="variable=instance_name,value=${UNIT_NAME},type=string"    \
    --provision-input-variables="variable=tenant_project_id,value=${TENANT_PROJECT_ID},type=string"     \
    --provision-input-variables="variable=tenant_project_number,value=${TENANT_PROJECT_NUMBER},type=int"     \
    --provision-input-variables="variable=actuation_sa,value=${ACTUATION_SA},type=string"     \
    --location="${GOOGLE_CLOUD_REGION}"   \
    --project="${GOOGLE_CLOUD_PROJECT}"


