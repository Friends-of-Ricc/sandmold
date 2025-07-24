#!/bin/bash
#
# Creates a regional SaaS Offering.
#

if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --saas-name)
            SAAS_OFFERING_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# --- Delete existing SaaS Offering (if it exists) ---
# Note: We attempt deletion from the new regional location.
# The old global one will be orphaned if it exists, but new deployments will be clean.
# echo "Attempting to delete old SaaS Offering '${SAAS_OFFERING_NAME}' from region '${GOOGLE_CLOUD_REGION}' (if it exists)..."
# gcloud beta saas-runtime saas delete "${SAAS_OFFERING_NAME}" \
#     --location="${GOOGLE_CLOUD_REGION}" \
#     --project="${GOOGLE_CLOUD_PROJECT}" \
#     --quiet || true # Continue if it doesn't exist or deletion fails

# --- Create Regional SaaS Offering ---
echo "Creating Regional SaaS Offering '${SAAS_OFFERING_NAME}' in '${GOOGLE_CLOUD_REGION}'..."
gcloud beta saas-runtime saas create "${SAAS_OFFERING_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --locations="name=${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "SaaS Offering setup complete."
