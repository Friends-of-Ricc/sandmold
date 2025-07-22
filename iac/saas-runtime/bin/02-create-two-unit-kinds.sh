#!/bin/bash
#
# Creates two Unit Kinds for the SaaS Offering: a global and a regional one.
#

set -euo pipefail

# Source the environment variables
source .env

UNIT_KIND_GLOBAL="${UNIT_KIND_NAME_BASE}-global"
UNIT_KIND_REGIONAL="${UNIT_KIND_NAME_BASE}-regional"

SAAS_OFFERING_GLOBAL="${SAAS_OFFERING_NAME}-global"
SAAS_OFFERING_REGIONAL="${SAAS_OFFERING_NAME}-regional"

# --- Create Global Unit Kind ---
echo "Checking for Global Unit Kind '${UNIT_KIND_GLOBAL}'..."
if ! gcloud beta saas-runtime unit-kinds describe "${UNIT_KIND_GLOBAL}" --saas="${SAAS_OFFERING_GLOBAL}" --location=global --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating Global Unit Kind '${UNIT_KIND_GLOBAL}'..."
    gcloud beta saas-runtime unit-kinds create "${UNIT_KIND_GLOBAL}" \
        --saas="${SAAS_OFFERING_GLOBAL}" \
        --location=global \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Global Unit Kind '${UNIT_KIND_GLOBAL}' already exists."
fi

# --- Create Regional Unit Kind ---
echo "Checking for Regional Unit Kind '${UNIT_KIND_REGIONAL}'..."
if ! gcloud beta saas-runtime unit-kinds describe "${UNIT_KIND_REGIONAL}" --saas="${SAAS_OFFERING_REGIONAL}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating Regional Unit Kind '${UNIT_KIND_REGIONAL}'..."
    gcloud beta saas-runtime unit-kinds create "${UNIT_KIND_REGIONAL}" \
        --saas="${SAAS_OFFERING_REGIONAL}" \
        --location="${GOOGLE_CLOUD_REGION}" \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Regional Unit Kind '${UNIT_KIND_REGIONAL}' already exists."
fi

echo "Unit Kind setup complete."
