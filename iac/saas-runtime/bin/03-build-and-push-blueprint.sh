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

# Source the environment variables
source .envrc

# --- Build Setup ---
BUILD_DIR="build/$(basename "${TERRAFORM_MODULE_DIR}")"
BLUEPRINT_IMAGE_NAME="$(basename "${TERRAFORM_MODULE_DIR}")-blueprint"
IMAGE_URI="${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}/${BLUEPRINT_IMAGE_NAME}:latest"

echo "Preparing temporary build directory: ${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cp -r "${TERRAFORM_MODULE_DIR}/." "${BUILD_DIR}/"

# --- Generate Dockerfile.Blueprint ---
echo "Generating Dockerfile.Blueprint in ${BUILD_DIR}..."
cat <<EOF > "${BUILD_DIR}/Dockerfile.Blueprint"
# syntax=docker/dockerfile:1-labs
FROM scratch
COPY --exclude=Dockerfile.Blueprint --exclude=.git --exclude=.gitignore . /
EOF

# --- Generate cloudbuild.yaml ---
echo "Generating cloudbuild.yaml in ${BUILD_DIR}..."
cat <<EOF > "${BUILD_DIR}/cloudbuild.yaml"
steps:
- id: 'Create Dockerfile'
  name: 'bash'
  args: ['-c', 'echo -e "# syntax=docker/dockerfile:1-labs\\nFROM scratch\\nCOPY --exclude=Dockerfile.Blueprint --exclude=.git --exclude=.gitignore . /" > Dockerfile.Blueprint']
- id: 'Create docker-container driver'
  name: 'docker'
  args: ['buildx', 'create', '--name', 'container', '--driver=docker-container']
- id: 'Build and Push docker image'
  name: 'docker'
  args: ['buildx', 'build', '-t', '\${_IMAGE_NAME}', '--builder=container', '--push', '--annotation', 'com.easysaas.engine.type=\${_ENGINE_TYPE}','--annotation', 'com.easysaas.engine.version=\${_ENGINE_VERSION}', '--provenance=false','-f', 'Dockerfile.Blueprint', '.']
substitutions:
  _IMAGE_NAME: "${IMAGE_URI}"
  _ENGINE_TYPE: 'inframanager'
  _ENGINE_VERSION: '1.5.7' # Using a known stable version
options:
  logging: CLOUD_LOGGING_ONLY
EOF

# --- Submit Build ---
echo "Submitting Cloud Build job for blueprint: ${BLUEPRINT_IMAGE_NAME}"
gcloud builds submit "${BUILD_DIR}" \
    --config="${BUILD_DIR}/cloudbuild.yaml" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "Blueprint build and push complete for ${BLUEPRINT_IMAGE_NAME}."
