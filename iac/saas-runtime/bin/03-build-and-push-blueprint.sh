#!/bin/bash
#
# Builds a generic Terraform blueprint and pushes it to Artifact Registry.
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

# --- Create Dockerfile.Blueprint ---
echo "Generating Dockerfile.Blueprint in ${BUILD_DIR}"
cat <<EOF > "${BUILD_DIR}/Dockerfile.Blueprint"
# syntax=docker/dockerfile:1-labs
FROM scratch
COPY --exclude=Dockerfile.Blueprint --exclude=.git --exclude=.gitignore . /
EOF

# --- Define Image Tags ---
BLUEPRINT_IMAGE_BASE_TAG="${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}/${TERRAFORM_MODULE_BASENAME}"
TIMESTAMP_TAG="autotag-$(date +%Y%m%d-%H%M)"
BLUEPRINT_IMAGE_TIMESTAMP_TAG="${BLUEPRINT_IMAGE_BASE_TAG}:${TIMESTAMP_TAG}"

# --- Generate cloudbuild.yaml ---
CLOUDBUILD_CONFIG_FILE="${BUILD_DIR}/cloudbuild.yaml"

echo "Generating cloudbuild.yaml in ${BUILD_DIR}"
cat <<EOF > "${CLOUDBUILD_CONFIG_FILE}"
steps:
- id: 'Create Dockerfile'
  name: 'ubuntu'
  entrypoint: 'bash'
  args:
  - '-c'
  - 'echo -e "# syntax=docker/dockerfile:1-labs\nFROM scratch\nCOPY --exclude=Dockerfile.Blueprint --exclude=.git --exclude=.gitignore . /" > /workspace/Dockerfile.Blueprint'
- id: 'Create docker-container driver'
  name: 'docker'
  args:
  - 'buildx'
  - 'create'
  - '--name'
  - 'container'
  - '--driver=docker-container'
- id: 'Build and Push Blueprint image'
  name: 'docker'
  args:
  - 'buildx'
  - 'build'
  - '--builder=container'
  - '--push'
  - '--annotation'
  - 'com.easysaas.engine.type=inframanager'
  - '--annotation'
  - 'com.easysaas.engine.version=1.5.7'
  - '-f'
  - '/workspace/Dockerfile.Blueprint'
  - '.'
  - '-t'
  - '${BLUEPRINT_IMAGE_BASE_TAG}'
  - '-t'
  - '${BLUEPRINT_IMAGE_TIMESTAMP_TAG}'
options:
  logging: CLOUD_LOGGING_ONLY
serviceAccount: projects/${GOOGLE_CLOUD_PROJECT}/serviceAccounts/${TF_ACTUATOR_SA_EMAIL}
EOF

# --- Submit Build ---
echo "Submitting Cloud Build job for blueprint: ${TERRAFORM_MODULE_BASENAME}"
gcloud builds submit "${BUILD_DIR}" \
    --config="${CLOUDBUILD_CONFIG_FILE}" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "Blueprint build and push complete for ${TERRAFORM_MODULE_BASENAME}."