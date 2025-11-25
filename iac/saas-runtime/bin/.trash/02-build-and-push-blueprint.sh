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

