#!/bin/bash
#
# Creates a Release for a given Unit Kind and Blueprint.
#

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
RELEASE_NAME=${1:-$RELEASE_NAME_BASE}
UNIT_KIND_NAME="${UNIT_KIND_NAME_BASE}"
TERRAFORM_MODULE_BASENAME="terraform-vm"

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
