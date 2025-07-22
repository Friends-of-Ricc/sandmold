#!/bin/bash
#
# Creates the Unit Kind for the SaaS Offering.
#

set -euo pipefail

# Source the environment variables
source .env

echo "Checking for Unit Kind '${UNIT_KIND_NAME}'..."
if ! gcloud beta saas-runtime unit-kinds describe "${UNIT_KIND_NAME}" --saas="${SAAS_OFFERING_NAME}" --location=global --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating Unit Kind '${UNIT_KIND_NAME}'..."
    gcloud beta saas-runtime unit-kinds create "${UNIT_KIND_NAME}" \
        --saas="${SAAS_OFFERING_NAME}" \
        --location=global \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Unit Kind '${UNIT_KIND_NAME}' already exists."
fi

echo "Unit Kind setup complete."