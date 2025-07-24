#!/bin/bash
#
# Triggers provisioning for a specific SaaS Unit.
#

set -euo pipefail
if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# --- Argument Check ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --unit-name)
            UNIT_NAME="$2"
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

# --- Environment and Config ---
source .env
if [ -f .env.post ]; then
    source .env.post
fi

TENANT_PROJECT_ID="${GOOGLE_CLOUD_PROJECT}"
TENANT_PROJECT_NUMBER=$(gcloud projects describe "${TENANT_PROJECT_ID}" --format="value(projectNumber)")
ACTUATION_SA="${TF_ACTUATOR_SA_EMAIL}"

# Construct the full Unit resource name
UNIT_RESOURCE_NAME="projects/${GOOGLE_CLOUD_PROJECT}/locations/${GOOGLE_CLOUD_REGION}/units/${UNIT_NAME}"

# --- Trigger Provisioning Unit Operation ---
echo "Triggering provisioning for Unit '${UNIT_NAME}'..."
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