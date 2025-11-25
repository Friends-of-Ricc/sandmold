#!/bin/bash
# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Builds a generic Terraform blueprint and pushes it to Artifact Registry.
#

set -euo pipefail

# Check for required argument
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --terraform-module-dir)
            TERRAFORM_MODULE_DIR="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done
TERRAFORM_MODULE_BASENAME=$(basename "${TERRAFORM_MODULE_DIR}")

source "$(dirname "$0")/common-setup.sh"

if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# --- Build Setup ---
BUILD_DIR="build/${TERRAFORM_MODULE_BASENAME}"

echo "Preparing temporary build directory: ${BUILD_DIR}"
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cp -r "${TERRAFORM_MODULE_DIR}/." "${BUILD_DIR}/"

# --- Create Dockerfile.Blueprint ---
# Ricc: USELESS since CB creates it!
# echo "Generating Dockerfile.Blueprint in ${BUILD_DIR}"
# cat <<EOF > "${BUILD_DIR}/Dockerfile.Blueprint"
# # syntax=docker/dockerfile:1-labs
# FROM scratch
# COPY --exclude=Dockerfile.Blueprint --exclude=.git --exclude=.gitignore . /
# EOF

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
(
    cd "${BUILD_DIR}" || exit
    zip -r blueprint.zip .
)
gcloud storage cp "${BUILD_DIR}/blueprint.zip" "gs://${TF_BLUEPRINT_BUCKET}/${TERRAFORM_MODULE_BASENAME}/blueprint.zip"

gcloud builds submit "gs://${TF_BLUEPRINT_BUCKET}/${TERRAFORM_MODULE_BASENAME}/blueprint.zip"     --config="${CLOUDBUILD_CONFIG_FILE}"     --project="${GOOGLE_CLOUD_PROJECT}"

echo "Blueprint build and push complete for ${TERRAFORM_MODULE_BASENAME}."
