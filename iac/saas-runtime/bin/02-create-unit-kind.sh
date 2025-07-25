#!/bin/bash
#
# Creates a regional Unit Kind for the SaaS Offering.
#

set -euo pipefail

source "$(dirname "$0")/common-setup.sh"

if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --unit-kind-name)
            UNIT_KIND_NAME="$2"
            shift 2
            ;;
        --saas-name)
            SAAS_OFFERING_NAME="$2"
            shift 2
            ;;
        --unit-kind-definition-json)
            UNIT_KIND_DEFINITION_JSON="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -n "${UNIT_KIND_DEFINITION_JSON}" ]; then
    UNIT_KIND_NAME=$(echo "${UNIT_KIND_DEFINITION_JSON}" | jq -r '.name')
    SAAS_OFFERING_NAME=$(echo "${UNIT_KIND_DEFINITION_JSON}" | jq -r '.saas_name')
fi

# --- Create Regional Unit Kind ---
echo "Checking for Unit Kind '${UNIT_KIND_NAME}'..."
# Note: saas-runtime doesn't have a good describe for unit-kinds without knowing the saas offering.
# We will attempt to create and let it fail if it exists.
gcloud beta saas-runtime unit-kinds create "${UNIT_KIND_NAME}" \
    --saas="${SAAS_OFFERING_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}" || echo "Unit Kind '${UNIT_KIND_NAME}' may already exist. Continuing..."

echo "Unit Kind setup complete."