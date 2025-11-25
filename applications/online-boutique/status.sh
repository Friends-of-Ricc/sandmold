#!/usr/bin/env bash
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

set -e
set -o pipefail

source "$(dirname "$0")/../_common.sh"

check_env_vars

log_to_gcp "status" "Application status check initiated."

echo "--- Checking Online Boutique Deployment Status ---"

echo "--> Configuring kubectl for project ${PROJECT_ID} and cluster ${CLUSTER_NAME}..."
gcloud container clusters get-credentials "${CLUSTER_NAME}" --region "${CLUSTER_LOCATION}" --project "${PROJECT_ID}"

echo "--> Getting status of frontend-external service..."
EXTERNAL_IP=$(kubectl get service frontend-external -n default -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$EXTERNAL_IP" ]; then
    log_to_gcp "status" "Application frontend is not available."
    echo "--- ❌ Online Boutique is not running ---"
else
    log_to_gcp "status" "Application frontend is available at: http://${EXTERNAL_IP}"
    echo "--- ✅ Online Boutique is running ---"
    echo "Application frontend is available at: http://${EXTERNAL_IP}"
fi