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
# Creates the SaaS Offering.
#

set -euo pipefail

# Source the environment variables
source .env

echo "Checking for SaaS Offering..."
if ! gcloud beta saas-runtime saas describe "${SAAS_OFFERING_NAME}" --location=global --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Creating SaaS Offering '${SAAS_OFFERING_NAME}'..."
    gcloud beta saas-runtime saas create "${SAAS_OFFERING_NAME}" \
        --location=global \
        --locations="name=${GOOGLE_CLOUD_REGION}" \
        --project="${GOOGLE_CLOUD_PROJECT}"

else
    echo "SaaS Offering '${SAAS_OFFERING_NAME}' already exists."
fi

echo "SaaS Offering setup complete."

