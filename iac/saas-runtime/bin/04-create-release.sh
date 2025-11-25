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
# Creates a Release for a given Unit Kind and Blueprint.
#

set -euo pipefail
if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

source "$(dirname "$0")/common-setup.sh"

# --- Configuration ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --release-name)
            RELEASE_NAME="$2"
            shift 2
            ;;
        --unit-kind-name)
            UNIT_KIND_NAME="$2"
            shift 2
            ;;
        --terraform-module-dir)
            TERRAFORM_MODULE_DIR="$2"
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
TERRAFORM_MODULE_BASENAME=$(basename "${TERRAFORM_MODULE_DIR}")

# Convert JSON input variables to gcloud format
INPUT_VARIABLE_DEFAULTS_ARGS=()
if [ -n "${INPUT_VARIABLES_JSON}" ]; then
    while IFS= read -r line; do
        INPUT_VARIABLE_DEFAULTS_ARGS+=(--input-variable-defaults="${line}")
    done < <(echo "${INPUT_VARIABLES_JSON}" | jq -r '.[] | "variable=\(.name),value=\(.value),type=\(.type)"')
fi

# Add constant variables
CONSTANT_VARIABLES=(
    "variable=tenant_project_id,value=${GOOGLE_CLOUD_PROJECT},type=string"
    "variable=tenant_project_number,value=${PROJECT_NUMBER},type=int"
    "variable=actuation_sa,value=${TF_ACTUATOR_SA_EMAIL},type=string"
)

for VAR in "${CONSTANT_VARIABLES[@]}"; do
    INPUT_VARIABLE_DEFAULTS_ARGS+=(--input-variable-defaults="${VAR}")
done

# --- Check and Create Release ---
echo "Checking for Release '${RELEASE_NAME}' for Unit Kind '${UNIT_KIND_NAME}'..."

# The blueprint package path now points to the Artifact Registry image.
BLUEPRINT_IMAGE_BASE_TAG="${GOOGLE_CLOUD_REGION}-docker.pkg.dev/${GOOGLE_CLOUD_PROJECT}/${ARTIFACT_REGISTRY_NAME}/${TERRAFORM_MODULE_BASENAME}"

RELEASE_NAME_WITH_TIMESTAMP="${RELEASE_NAME}-$(date +%Y%m%d-%H%M)"

gcloud beta saas-runtime releases create "${RELEASE_NAME_WITH_TIMESTAMP}" \
    --unit-kind="${UNIT_KIND_NAME}" \
    --blueprint-package="${BLUEPRINT_IMAGE_BASE_TAG}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    "${INPUT_VARIABLE_DEFAULTS_ARGS[@]}" \
    --project="${GOOGLE_CLOUD_PROJECT}" --format="value(name)"
