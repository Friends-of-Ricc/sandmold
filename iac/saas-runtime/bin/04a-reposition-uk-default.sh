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


set -euo pipefail
if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

source "$(dirname "$0")/common-setup.sh"

# --- Configuration ---
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --unit-kind-name)
            UNIT_KIND_NAME="$2"
            shift 2
            ;;
        --release-name)
            RELEASE_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo "Repositioning Unit Kind '${UNIT_KIND_NAME}' default release to '${RELEASE_NAME}'..."

gcloud beta saas-runtime unit-kinds update "${UNIT_KIND_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --default-release="${RELEASE_NAME}" \
    --project="${GOOGLE_CLOUD_PROJECT}"

echo "Unit Kind default release updated."

