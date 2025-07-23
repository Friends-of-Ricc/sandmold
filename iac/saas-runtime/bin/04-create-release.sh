#!/bin/bash
#
# Creates a Release for a given Unit Kind and Blueprint.
#

set -euo pipefail
set -x

# Source the environment variables
source .env
if [ -f .env.post ]; then
    source .env.post
fi

# --- Configuration ---
RELEASE_NAME="${RELEASE_NAME_BASE}"
UNIT_KIND_NAME="${UNIT_KIND_NAME_BASE}"

# --- Check and Create Release ---
echo "Checking for Release '${RELEASE_NAME}' for Unit Kind '${UNIT_KIND_NAME}'..."

gcloud beta saas-runtime releases create "${RELEASE_NAME}" \
    --unit-kind="${UNIT_KIND_NAME}" \
    --blueprint-package="https://storage.googleapis.com/${TF_BLUEPRINT_BUCKET}/terraform-vm/terraform-vm.zip" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --input-variable-defaults="variable=instance_name,value=default-instance,type=string" \
    --input-variable-defaults="variable=tenant_project_id,value=${GOOGLE_CLOUD_PROJECT},type=string" \
    --input-variable-defaults="variable=tenant_project_number,value=${PROJECT_NUMBER},type=int" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "Release setup complete."