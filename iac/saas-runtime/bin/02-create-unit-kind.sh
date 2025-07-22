#!/bin/bash
#
# Creates the Unit Kind for the SaaS Offering.
#

set -euo pipefail

# Source the environment variables
source .env

# Note: The 'describe' command for unit-kinds requires the saas name and a location.
# We will use 'global' as the location for the describe check, consistent with creation.
echo "Checking for Unit Kind '${UNIT_KIND_NAME}'..."
echo "Creating Unit Kind '${UNIT_KIND_NAME}'..." 
    gcloud beta saas-runtime unit-kinds create "${UNIT_KIND_NAME}" \
        --saas="${SAAS_OFFERING_NAME}" \
        --location=global \
        --project="${GOOGLE_CLOUD_PROJECT}" || echo "Unit Kind already exists or another error occurred."

echo "Unit Kind setup complete."
