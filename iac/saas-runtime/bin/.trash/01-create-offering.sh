#!/bin/bash
#
# Creates the SaaS Offering.
#

set -euo pipefail

# Source the environment variables
source .envrc

echo "Checking for SaaS Offering..."
if ! gcloud beta saas-runtime saas describe "${SAAS_OFFERING_NAME}" --location=global --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating SaaS Offering '${SAAS_OFFERING_NAME}'..."
    gcloud beta saas-runtime saas create "${SAAS_OFFERING_NAME}" \
        --location=global \
        --locations="name=${GOOGLE_CLOUD_REGION}" \
        --project="${GOOGLE_CLOUD_PROJECT}"

else
    echo "SaaS Offering '${SAAS_OFFERING_NAME}' already exists."
fi

echo "SaaS Offering setup complete."

