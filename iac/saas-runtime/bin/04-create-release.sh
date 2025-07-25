#!/bin/bash
#
# Creates a Release for a given Unit Kind and Blueprint.
#

set -euo pipefail
if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

source "$(dirname "$0")/common-setup.sh"

# --- Configuration ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --release-name)
            RELEASE_NAME="$2"
            shift 2
            ;;
        --unit-kind-name)
            UNIT_KIND_NAME="$2"
            shift 2
            ;;
        --terraform-module-dir)
            TERRAFORM_MODULE_DIR="$2"
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
TERRAFORM_MODULE_BASENAME=$(basename "${TERRAFORM_MODULE_DIR}")

# Convert JSON input variables to gcloud format
INPUT_VARIABLE_DEFAULTS=""
if [ -n "${INPUT_VARIABLES_JSON}" ]; then
    # Parse JSON and format for gcloud
    # Example: {"instance_name":"my-vm"} -> variable=instance_name,value=my-vm,type=string
    INPUT_VARIABLE_DEFAULTS=$(echo "${INPUT_VARIABLES_JSON}" | jq -r '.[] | "variable=\(.name),value=\(.value),type=\(.type)"' | paste -sd " " -)
fi

# Add constant variables
CONSTANT_VARIABLES=(
    "variable=tenant_project_id,value=${GOOGLE_CLOUD_PROJECT},type=string"
    "variable=tenant_project_number,value=${PROJECT_NUMBER},type=int"
    "variable=actuation_sa,value=${TF_ACTUATOR_SA_EMAIL},type=string"
)

for VAR in "${CONSTANT_VARIABLES[@]}"; do
    if [ -n "${INPUT_VARIABLE_DEFAULTS}" ]; then
        INPUT_VARIABLE_DEFAULTS="${INPUT_VARIABLE_DEFAULTS} ${VAR}"
    else
        INPUT_VARIABLE_DEFAULTS="${VAR}"
    fi
done

# --- Check and Create Release ---
echo "Checking for Release '${RELEASE_NAME}' for Unit Kind '${UNIT_KIND_NAME}'..."

# The blueprint package path now points to the Artifact Registry image.
BLUEPRINT_IMAGE_BASE_TAG="${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}/${TERRAFORM_MODULE_BASENAME}"

RELEASE_NAME_WITH_TIMESTAMP="${RELEASE_NAME}-$(date +%Y%m%d-%H%M)"

gcloud beta saas-runtime releases create "${RELEASE_NAME_WITH_TIMESTAMP}" \
    --unit-kind="${UNIT_KIND_NAME}" \
    --blueprint-package="${BLUEPRINT_IMAGE_BASE_TAG}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --input-variable-defaults="${INPUT_VARIABLE_DEFAULTS}" \
    --project="${GOOGLE_CLOUD_PROJECT}" --format="value(name)"
