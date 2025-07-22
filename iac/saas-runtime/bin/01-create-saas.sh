#!/bin/bash
#
# Creates the Global and Regional SaaS Offerings.
#

set -euo pipefail

# Source the environment variables
source .env

# Define the full names for the global and regional SaaS offerings
SAAS_OFFERING_GLOBAL="${SAAS_OFFERING_NAME}-global"
SAAS_OFFERING_REGIONAL="${SAAS_OFFERING_NAME}-regional"

# --- Delete existing SaaS Offering (if it exists) ---
echo "Attempting to delete old SaaS Offering '${SAAS_OFFERING_NAME}' (if it exists)..."
gcloud beta saas-runtime saas delete "${SAAS_OFFERING_NAME}" \
    --location=global \
    --project="${GOOGLE_CLOUD_PROJECT}" \
    --quiet || true # Continue if it doesn't exist or deletion fails

# --- Create Global SaaS Offering ---
echo "Creating Global SaaS Offering '${SAAS_OFFERING_GLOBAL}'..."
gcloud beta saas-runtime saas create "${SAAS_OFFERING_GLOBAL}" \
    --location=global \
    --locations="name=${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}" || true

echo "Creating Regional SaaS Offering '${SAAS_OFFERING_REGIONAL}'..."
gcloud beta saas-runtime saas create "${SAAS_OFFERING_REGIONAL}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --locations="name=${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}" || true

echo "SaaS Offering setup complete."