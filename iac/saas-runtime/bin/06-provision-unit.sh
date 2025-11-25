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
# Triggers provisioning for a specific SaaS Unit.
#

set -euo pipefail
if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# --- Argument Check ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --unit-name)
            UNIT_NAME="$2"
            shift 2
            ;;
        --release-name)
            RELEASE_NAME="$2"
            shift 2
            ;;
        --input-variables-json)
            INPUT_VARIABLES_JSON="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

source "$(dirname "$0")/common-setup.sh"

TENANT_PROJECT_ID="${GOOGLE_CLOUD_PROJECT}"
TENANT_PROJECT_NUMBER=$(gcloud projects describe "${TENANT_PROJECT_ID}" --format="value(projectNumber)")
ACTUATION_SA="${TF_ACTUATOR_SA_EMAIL}"

# Convert JSON input variables to gcloud format
PROVISION_INPUT_VARIABLES_ARGS=()
if [ -n "${INPUT_VARIABLES_JSON}" ]; then
    while IFS= read -r line; do
        PROVISION_INPUT_VARIABLES_ARGS+=(--provision-input-variables="${line}")
    done < <(echo "${INPUT_VARIABLES_JSON}" | jq -r '.[] | "variable=\(.name),value=\(.value),type=\(.type)"')
fi

# Add constant variables
CONSTANT_VARIABLES=(
    "variable=tenant_project_id,value=${TENANT_PROJECT_ID},type=string"
    "variable=tenant_project_number,value=${TENANT_PROJECT_NUMBER},type=int"
    "variable=actuation_sa,value=${ACTUATION_SA},type=string"
)

for VAR in "${CONSTANT_VARIABLES[@]}"; do
    PROVISION_INPUT_VARIABLES_ARGS+=(--provision-input-variables="${VAR}")
done

# Construct the full Unit resource name
UNIT_RESOURCE_NAME="projects/${GOOGLE_CLOUD_PROJECT}/locations/${GOOGLE_CLOUD_REGION}/units/${UNIT_NAME}"

# --- Trigger Provisioning Unit Operation ---
echo "Triggering provisioning for Unit '${UNIT_NAME}'..."
gcloud --log-http beta saas-runtime unit-operations create "provision-${UNIT_NAME}-$(date +%s)" \
    --unit="${UNIT_RESOURCE_NAME}" \
    --provision \
    --provision-release="${RELEASE_NAME}" \
    "${PROVISION_INPUT_VARIABLES_ARGS[@]}" \
    --location="${GOOGLE_CLOUD_REGION}"   \
    --project="${GOOGLE_CLOUD_PROJECT}"