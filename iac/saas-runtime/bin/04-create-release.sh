#!/bin/bash
#
# Creates a Release for a given Unit Kind and Blueprint.
#

set -euo pipefail

# Source the environment variables
source .env

# --- Configuration ---
BLUEPRINT_IMAGE_NAME="terraform-vm-blueprint" # This should match the output of the build script
IMAGE_URI="${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}/${BLUEPRINT_IMAGE_NAME}:latest"

# --- Check and Create Release ---
echo "Checking for Release '${RELEASE_NAME}' for Unit Kind '${UNIT_KIND_NAME}'..."

# Note: The 'describe' command for releases requires the unit-kind and a location.
# We will use 'global' as the location for the describe check, consistent with creation.
if ! gcloud beta saas-runtime releases describe "${RELEASE_NAME}" \
    --unit-kind="${UNIT_KIND_NAME}" \
    --location=global \
    --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then

    echo "Creating Release '${RELEASE_NAME}'..."
    gcloud beta saas-runtime releases create "${RELEASE_NAME}" \
        --unit-kind="${UNIT_KIND_NAME}" \
        --blueprint-package="${IMAGE_URI}" \
        --location=global \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Release '${RELEASE_NAME}' already exists."
fi

echo "Release setup complete."
