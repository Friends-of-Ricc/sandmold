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

log_to_gcp "stop" "Application stop sequence initiated."

echo "--- Stopping Online Boutique Deployment ---"

echo "--> Configuring kubectl for project ${PROJECT_ID} and cluster ${CLUSTER_NAME}..."
gcloud container clusters get-credentials "${CLUSTER_NAME}" --region "${CLUSTER_LOCATION}" --project "${PROJECT_ID}"

ONLINE_BOUTIQUE_DIR="vendor/microservices-demo"
if [ ! -d "$ONLINE_BOUTIQUE_DIR" ]; then
    echo "--> Online Boutique repository not found, skipping cleanup."
    exit 0
fi

echo "--> Deleting Online Boutique manifests..."
kubectl delete -f "${ONLINE_BOUTIQUE_DIR}/release/kubernetes-manifests.yaml"

log_to_gcp "stop" "Application stopped successfully."

echo "--- ✅ Online Boutique Stopped Successfully ---"