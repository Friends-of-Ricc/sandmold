#!/bin/bash
#
# Creates a Release for a given Unit Kind and Blueprint.
#

set -euo pipefail

# Check for required argument
if [ -z "$1" ]; then
    echo "Usage: $0 <unit-kind-name>"
    exit 1
fi

UNIT_KIND_TO_USE=$1

# Source the environment variables
source .env

# Determine the Release Name based on the Unit Kind's location
if [[ "${UNIT_KIND_TO_USE}" == *"-regional"* ]]; then
    RELEASE_NAME_SUFFIX="-regional"
    RELEASE_LOCATION="${GOOGLE_CLOUD_REGION}"
else
    RELEASE_NAME_SUFFIX="-global"
    RELEASE_LOCATION="global"
fi
RELEASE_NAME="${RELEASE_NAME_BASE}${RELEASE_NAME_SUFFIX}"

# --- Configuration ---
BLUEPRINT_IMAGE_NAME="terraform-vm-blueprint" # This should match the output of the build script
IMAGE_URI="${RELEASE_LOCATION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}/${BLUEPRINT_IMAGE_NAME}:${RELEASE_NAME}"

# --- Check and Create Release ---
echo "Checking for Release '${RELEASE_NAME}' for Unit Kind '${UNIT_KIND_TO_USE}'..."

# Note: The 'describe' command for releases requires the unit-kind and a location.
# We will use 'global' as the location for the describe check, consistent with creation.
if [[ "${UNIT_KIND_TO_USE}" == *"-regional"* ]]; then
    RELEASE_LOCATION="${GOOGLE_CLOUD_REGION}"
else
    RELEASE_LOCATION="global"
fi

# --- Check and Create Release ---
echo "Checking for Release '${RELEASE_NAME}' for Unit Kind '${UNIT_KIND_TO_USE}'..."

# Note: The 'describe' command for releases requires the unit-kind and a location.
if ! gcloud beta saas-runtime releases describe "${RELEASE_NAME}" \
    --unit-kind="${UNIT_KIND_TO_USE}" \
    --location=${RELEASE_LOCATION} \
    --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then

    echo "Creating Release '${RELEASE_NAME}'..."
    gcloud --log-http beta saas-runtime releases create "${RELEASE_NAME}"         --unit-kind="${UNIT_KIND_TO_USE}"         --blueprint-package="${RELEASE_LOCATION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}/${BLUEPRINT_IMAGE_NAME}@sha256:8506c2f9154ae67bb5eeca56183d0f6aff0f29a10a39e2d93ce2bbccda88692d"         --location=${RELEASE_LOCATION}         --input-variable-defaults="variable=instance_name,value=default-instance,type=string"         --input-variable-defaults="variable=tenant_project_id,value=${GOOGLE_CLOUD_PROJECT},type=string"         --input-variable-defaults="variable=tenant_project_number,value=${PROJECT_NUMBER},type=string"         --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Release '${RELEASE_NAME}' already exists."
fi

echo "Release setup complete."
