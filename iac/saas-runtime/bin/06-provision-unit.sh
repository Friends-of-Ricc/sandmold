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
        --input-variables-json)
            INPUT_VARIABLES_JSON="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

source "$(dirname "$0")/common-setup.sh"

TENANT_PROJECT_ID="${GOOGLE_CLOUD_PROJECT}"
TENANT_PROJECT_NUMBER=$(gcloud projects describe "${TENANT_PROJECT_ID}" --format="value(projectNumber)")
ACTUATION_SA="${TF_ACTUATOR_SA_EMAIL}"

# Convert JSON input variables to gcloud format
PROVISION_INPUT_VARIABLES=""
if [ -n "${INPUT_VARIABLES_JSON}" ]; then
    # Parse JSON and format for gcloud
    # Example: {"instance_name":"my-vm"} -> variable=instance_name,value=my-vm,type=string
    PROVISION_INPUT_VARIABLES=$(echo "${INPUT_VARIABLES_JSON}" | jq -r '.[] | "variable=\(.name),value=\(.value),type=\(.type)"' | paste -sd " " -)
fi

# Add constant variables
CONSTANT_VARIABLES=(
    "variable=tenant_project_id,value=${TENANT_PROJECT_ID},type=string"
    "variable=tenant_project_number,value=${TENANT_PROJECT_NUMBER},type=int"
    "variable=actuation_sa,value=${ACTUATION_SA},type=string"
)

for VAR in "${CONSTANT_VARIABLES[@]}"; do
    if [ -n "${PROVISION_INPUT_VARIABLES}" ]; then
        PROVISION_INPUT_VARIABLES="${PROVISION_INPUT_VARIABLES} ${VAR}"
    else
        PROVISION_INPUT_VARIABLES="${VAR}"
    fi
done

# Construct the full Unit resource name
UNIT_RESOURCE_NAME="projects/${GOOGLE_CLOUD_PROJECT}/locations/${GOOGLE_CLOUD_REGION}/units/${UNIT_NAME}"

# --- Trigger Provisioning Unit Operation ---
echo "Triggering provisioning for Unit '${UNIT_NAME}'..."
gcloud --log-http beta saas-runtime unit-operations create "provision-${UNIT_NAME}-$(date +%s)" \
    --unit="${UNIT_RESOURCE_NAME}" \
    --provision \
    --provision-release="${RELEASE_NAME}" \
    --provision-input-variables="${PROVISION_INPUT_VARIABLES}" \
    --location="${GOOGLE_CLOUD_REGION}"   \
    --project="${GOOGLE_CLOUD_PROJECT}"