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
# Creates the Unit Kind and a Release.
#

set -euo pipefail

# Source the environment variables
source .env

IMAGE_URI="${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}/${BLUEPRINT_IMAGE_NAME}:latest"

# Create the Unit Kind
echo "Checking for Unit Kind '${UNIT_KIND_NAME}'..."
if ! gcloud beta saas-runtime unit-kinds describe "${UNIT_KIND_NAME}" --offering="${SAAS_OFFERING_NAME}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating Unit Kind '${UNIT_KIND_NAME}'..."
    gcloud beta saas-runtime unit-kinds create "${UNIT_KIND_NAME}" \
        --offering="${SAAS_OFFERING_NAME}" \
        --display-name="Sample VM" \
        --blueprint-repo="projects/${GOOGLE_CLOUD_PROJECT}/locations/${GOOGLE_CLOUD_REGION}/repositories/${ARTIFACT_REGISTRY_NAME}" \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Unit Kind '${UNIT_KIND_NAME}' already exists."
fi

# Create the Release
echo "Checking for Release '${RELEASE_NAME}'..."
if ! gcloud beta saas-runtime releases describe "${RELEASE_NAME}" --unit-kind="${UNIT_KIND_NAME}" --offering="${SAAS_OFFERING_NAME}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating Release '${RELEASE_NAME}'..."
    gcloud beta saas-runtime releases create "${RELEASE_NAME}" \
        --unit-kind="${UNIT_KIND_NAME}" \
        --offering="${SAAS_OFFERING_NAME}" \
        --blueprint-version="${IMAGE_URI}" \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Release '${RELEASE_NAME}' already exists."
fi

echo "Unit Kind and Release setup complete."
