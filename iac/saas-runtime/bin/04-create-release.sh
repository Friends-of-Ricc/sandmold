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
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done
TERRAFORM_MODULE_BASENAME=$(basename "${TERRAFORM_MODULE_DIR}")

# --- Check and Create Release ---
echo "Checking for Release '${RELEASE_NAME}' for Unit Kind '${UNIT_KIND_NAME}'..."

# The blueprint package path now points to the Artifact Registry image.
BLUEPRINT_IMAGE_BASE_TAG="${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}/${TERRAFORM_MODULE_BASENAME}"

gcloud beta saas-runtime releases create "${RELEASE_NAME}" \
    --unit-kind="${UNIT_KIND_NAME}" \
    --blueprint-package="${BLUEPRINT_IMAGE_BASE_TAG}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --input-variable-defaults="variable=instance_name,value=default-instance,type=string" \
    --input-variable-defaults="variable=tenant_project_id,value=${GOOGLE_CLOUD_PROJECT},type=string" \
    --input-variable-defaults="variable=tenant_project_number,value=${PROJECT_NUMBER},type=int" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "Release setup complete."
