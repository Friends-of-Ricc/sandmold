#!/bin/bash
#
# Builds a generic Terraform blueprint and pushes it to a GCS bucket.
#

set -euo pipefail

# Check for required argument
if [ -z "$1" ]; then
    echo "Usage: $0 <path-to-terraform-module>"
    exit 1
fi

TERRAFORM_MODULE_DIR=$1
TERRAFORM_MODULE_BASENAME=$(basename "${TERRAFORM_MODULE_DIR}")

# Source the environment variables
source .env
if [ -f .env.post ]; then
    source .env.post
fi

# --- Build Setup ---
BUILD_DIR="build/${TERRAFORM_MODULE_BASENAME}"

echo "Preparing temporary build directory: ${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cp -r "${TERRAFORM_MODULE_DIR}/." "${BUILD_DIR}/"

# --- Create ZIP archive ---
ZIP_FILE="${BUILD_DIR}.zip"
echo "Creating ZIP archive: ${ZIP_FILE}"
(cd "${BUILD_DIR}" && zip -r "../${TERRAFORM_MODULE_BASENAME}.zip" .)

# --- Upload ZIP to GCS ---
GCS_PATH="gs://${TF_BLUEPRINT_BUCKET}/${TERRAFORM_MODULE_BASENAME}/${TERRAFORM_MODULE_BASENAME}.zip"
echo "Uploading ZIP archive to GCS: ${GCS_PATH}"
gsutil cp "${ZIP_FILE}" "${GCS_PATH}"

# --- Generate cloudbuild.yaml ---
echo "Generating cloudbuild.yaml in ${BUILD_DIR}"
cat <<EOF > "${BUILD_DIR}/cloudbuild.yaml"
steps:
- id: 'Echo Debug'
  name: 'ubuntu/cloud-sdk:latest'
  entrypoint: 'bash'
  args:
  - '-c'
  - 'echo "DEBUG activated for sandmold."'
- id: 'Find Files'
  name: 'ubuntu/cloud-sdk:latest'
  entrypoint: 'bash'
  args:
  - '-c'
  - 'find .'
- id: 'Deploy Blueprint'
  name: 'gcr.io/cloud-foundation-toolkit/infra-manager:latest'
  args:
  - 'apply'
  - '--blueprint-path=${GCS_PATH}'
  - '--project=${GOOGLE_CLOUD_PROJECT}'
  - '--location=${GOOGLE_CLOUD_REGION}'
  - '--service-account=${TF_ACTUATOR_SA_EMAIL}'
options:
  logging: CLOUD_LOGGING_ONLY
EOF

# --- Submit Build ---
echo "Submitting Cloud Build job for blueprint: ${TERRAFM_MODULE_BASENAME}"
gcloud builds submit "${BUILD_DIR}" \
    --config="${BUILD_DIR}/cloudbuild.yaml" \
    --project="${GOOGLE_CLOUD_PROJECT}" \
    --substitutions=_ENGINE_TYPE='inframanager',_ENGINE_VERSION='1.5.7'

echo "Blueprint build and push complete for ${TERRAFORM_MODULE_BASENAME}."