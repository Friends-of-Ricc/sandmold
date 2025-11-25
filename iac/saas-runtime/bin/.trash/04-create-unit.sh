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
# Creates a Unit (an instance of the service).
#

set -euo pipefail

# Source the environment variables
source .env

# Create the Unit
echo "Checking for Unit '${UNIT_NAME}'..."
if ! gcloud beta saas-runtime units describe "${UNIT_NAME}" --release="${RELEASE_NAME}" --unit-kind="${UNIT_KIND_NAME}" --offering="${SAAS_OFFERING_NAME}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating Unit '${UNIT_NAME}'..."
    gcloud beta saas-runtime units create "${UNIT_NAME}" \
        --release="${RELEASE_NAME}" \
        --unit-kind="${UNIT_KIND_NAME}" \
        --offering="${SAAS_OFFERING_NAME}" \
        --parameters="project_id=${GOOGLE_CLOUD_PROJECT},instance_name=saas-vm-${UNIT_NAME}" \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Unit '${UNIT_NAME}' already exists."
fi

echo "Unit creation process started."

