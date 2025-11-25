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
# Creates a regional SaaS Offering.
#

set -euo pipefail

source "$(dirname "$0")/common-setup.sh"

if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --saas-name)
            SAAS_OFFERING_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# --- Delete existing SaaS Offering (if it exists) ---
# Note: We attempt deletion from the new regional location.
# The old global one will be orphaned if it exists, but new deployments will be clean.
# echo "Attempting to delete old SaaS Offering '${SAAS_OFFERING_NAME}' from region '${GOOGLE_CLOUD_REGION}' (if it exists)..."
# gcloud beta saas-runtime saas delete "${SAAS_OFFERING_NAME}" \
#     --location="${GOOGLE_CLOUD_REGION}" \
#     --project="${GOOGLE_CLOUD_PROJECT}" \
#     --quiet || true # Continue if it doesn't exist or deletion fails

# --- Create Regional SaaS Offering ---
echo "Creating Regional SaaS Offering '${SAAS_OFFERING_NAME}' in '${GOOGLE_CLOUD_REGION}'..."
gcloud beta saas-runtime saas create "${SAAS_OFFERING_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --locations="name=${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "SaaS Offering setup complete."
