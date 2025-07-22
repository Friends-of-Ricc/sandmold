#!/bin/bash
#
# Creates the SaaS Offering.
#

set -euo pipefail

# Source the environment variables
source .env

echo "Checking for SaaS Offering '${SAAS_OFFERING_NAME}'..."
if ! gcloud beta saas-runtime offerings describe "${SAAS_OFFERING_NAME}" --location=global --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating SaaS Offering '${SAAS_OFFERING_NAME}'..."
    gcloud beta saas-runtime offerings create "${SAAS_OFFERING_NAME}" \
        --location=global \
        --locations="name=${GOOGLE_CLOUD_REGION}" \
        --project="${GOOGLE_CLOUD_PROJECT}"
elseecho "SaaS Offering '${SAAS_OFFERING_NAME}' already exists."
fi

echo "SaaS Offering setup complete."

