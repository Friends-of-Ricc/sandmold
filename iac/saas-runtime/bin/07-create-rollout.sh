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
# Creates a Rollout Kind and a Rollout to trigger Unit provisioning.
#

set -euo pipefail
if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# Source the environment variables
source "$(dirname "$0")/common-setup.sh"

# --- Argument Check ---
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
        --rollout-kind-name)
            ROLLOUT_KIND_NAME="$2"
            shift 2
            ;;
        --rollout-name)
            ROLLOUT_NAME="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# --- Create Rollout Kind ---
echo "Checking for Rollout Kind '${ROLLOUT_KIND_NAME}'..."
gcloud beta saas-runtime rollout-kinds create "${ROLLOUT_KIND_NAME}" \
    --unit-kind="${UNIT_KIND_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --rollout-orchestration-strategy="Google.Cloud.Simple.AllAtOnce" \
    --project="${GOOGLE_CLOUD_PROJECT}" || echo "Rollout Kind '${ROLLOUT_KIND_NAME}' may already exist. Continuing..."

# --- Create Rollout ---
echo "Checking for Rollout '${ROLLOUT_NAME}'..."
gcloud beta saas-runtime rollouts create "${ROLLOUT_NAME}" \
    --release="${RELEASE_NAME}" \
    --rollout-kind="${ROLLOUT_KIND_NAME}" \
    --location="${GOOGLE_CLOUD_REGION}" \
    --project="${GOOGLE_CLOUD_PROJECT}" || echo "Rollout '${ROLLOUT_NAME}' may already exist. Continuing..."

echo "Rollout setup complete."
