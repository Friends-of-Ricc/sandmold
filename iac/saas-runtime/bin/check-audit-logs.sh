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
# Reads Cloud Audit Logs for errors and writes them to a file.
#

set -euo pipefail

source .env

LOG_FILE="log/audit_logs_$(date +%Y%m%d_%H%M%S).json"

TIMESTAMP_6_HOURS_AGO=$(date -u -v-6H +%Y-%m-%dT%H:%M:%SZ)

echo "Reading Cloud Audit Logs and writing to ${LOG_FILE}"
gcloud logging read 'resource.type=("saas_service_management.googleapis.com" OR "gcs_bucket" OR "cloud_build") AND severity>="ERROR"' --project="${GOOGLE_CLOUD_PROJECT}" --limit=100 --format=json | jq --arg ts "${TIMESTAMP_6_HOURS_AGO}" '.[] | select(.timestamp > $ts)' > "${LOG_FILE}"

echo "Audit logs saved to ${LOG_FILE}"


 #| grep -E "PROVISION|UPDATE|DELETE"
#gcloud beta saas-runtime unit-operations list --project="${GOOGLE_CLOUD_PROJECT}" --format="table(name, operationType, state, createTime)" > log/unit_operations_$(date +%Y%m%d_%H%M%S).txt
gcloud beta saas-runtime unit-operations list --project="${GOOGLE_CLOUD_PROJECT}" --format=yaml > log/unit_operations_$(date +%Y%m%d_%H%M%S).yaml
