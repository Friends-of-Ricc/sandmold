#!/bin/bash
#
# Creates the Unit Kinds for the SaaS Offering (global and regional).
#

set -euo pipefail

# Source the environment variables
source .env

# --- Delete existing Unit Kind (if it exists) ---
echo "Attempting to delete existing Unit Kind '${UNIT_KIND_NAME}' (if it exists)..."
gcloud beta saas-runtime unit-kinds delete "${UNIT_KIND_NAME}" \
    --location=global \
    --project="${GOOGLE_CLOUD_PROJECT}" \
    --quiet || true # Continue if it doesn't exist or deletion fails

# --- Create Global Unit Kind ---
echo "Checking for Global Unit Kind '${UNIT_KIND_NAME_GLOBAL}'..."
if ! gcloud beta saas-runtime unit-kinds describe "${UNIT_KIND_NAME_GLOBAL}" --saas="${SAAS_OFFERING_NAME}" --location=global --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating Global Unit Kind '${UNIT_KIND_NAME_GLOBAL}'..."
    gcloud beta saas-runtime unit-kinds create "${UNIT_KIND_NAME_GLOBAL}" \
        --saas="${SAAS_OFFERING_NAME}" \
        --location=global \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Global Unit Kind '${UNIT_KIND_NAME_GLOBAL}' already exists."
fi

# --- Create Regional Unit Kind ---
echo "Checking for Regional Unit Kind '${UNIT_KIND_NAME_REGIONAL}'..."
if ! gcloud beta saas-runtime unit-kinds describe "${UNIT_KIND_NAME_REGIONAL}" --saas="${SAAS_OFFERING_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating Regional Unit Kind '${UNIT_KIND_NAME_REGIONAL}'..."
    gcloud beta saas-runtime unit-kinds create "${UNIT_KIND_NAME_REGIONAL}" \
        --saas="${SAAS_OFFERING_NAME}" \
        --location="${GOOGLE_CLOUD_REGION}" \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Regional Unit Kind '${UNIT_KIND_NAME_REGIONAL}' already exists."
fi

echo "Unit Kind setup complete."

