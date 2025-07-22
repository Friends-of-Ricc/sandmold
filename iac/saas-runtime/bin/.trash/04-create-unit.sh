#!/bin/bash
#
# Creates a Unit (an instance of the service).
#

set -euo pipefail

# Source the environment variables
source .env

# Create the Unit
echo "Checking for Unit '${UNIT_NAME}'..."
if ! gcloud beta saas-runtime units describe "${UNIT_NAME}" --release="${RELEASE_NAME}" --unit-kind="${UNIT_KIND_NAME}" --offering="${SAAS_OFFERING_NAME}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating Unit '${UNIT_NAME}'..."
    gcloud beta saas-runtime units create "${UNIT_NAME}" \
        --release="${RELEASE_NAME}" \
        --unit-kind="${UNIT_KIND_NAME}" \
        --offering="${SAAS_OFFERING_NAME}" \
        --parameters="project_id=${GOOGLE_CLOUD_PROJECT},instance_name=saas-vm-${UNIT_NAME}" \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Unit '${UNIT_NAME}' already exists."
fi

echo "Unit creation process started."

