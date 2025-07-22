#!/bin/bash
#
# Builds the Terraform blueprint and pushes it to Artifact Registry.
#

set -euo pipefail

# Source the environment variables
source .env

# The directory containing the Terraform module and cloudbuild.yaml
TERRAFORM_DIR="terraform-modules/terraform-vm"

IMAGE_URI="${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}/${BLUEPRINT_IMAGE_NAME}:latest"

echo "Building and pushing blueprint from '${TERRAFORM_DIR}'..."

gcloud builds submit "${TERRAFORM_DIR}" \
    --config="${TERRAFORM_DIR}/cloudbuild.yaml" \
    --substitutions="_IMAGE_NAME=${IMAGE_URI},_SERVICE_ACCOUNT=${CLOUD_BUILD_SA}" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "Blueprint build and push complete."

