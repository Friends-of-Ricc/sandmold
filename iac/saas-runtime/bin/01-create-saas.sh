#!/bin/bash
#
# Creates a regional SaaS Offering.
#

set -euo pipefail
set -x

# Source the environment variables
source .env

# --- Delete existing SaaS Offering (if it exists) ---
# Note: We attempt deletion from the new regional location.
# The old global one will be orphaned if it exists, but new deployments will be clean.
echo "Attempting to delete old SaaS Offering '${SAAS_OFFERING_NAME}' from region '${GOOGLE_CLOUD_REGION}' (if it exists)..."
gcloud beta saas-runtime saas delete "${SAAS_OFFERING_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}" \
    --quiet || true # Continue if it doesn't exist or deletion fails

# --- Create Regional SaaS Offering ---
echo "Creating Regional SaaS Offering '${SAAS_OFFERING_NAME}' in '${GOOGLE_CLOUD_REGION}'..."
gcloud beta saas-runtime saas create "${SAAS_OFFERING_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --locations="name=${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "SaaS Offering setup complete."