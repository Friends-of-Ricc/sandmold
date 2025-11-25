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
# Retrieves error logs from Google Cloud Logging for the specified number of hours.
#
# Usage: $0 [HOURS]
#   HOURS: Optional. The number of hours to look back for logs. Defaults to 24.

set -euo pipefail

HOURS=${1:-24} # Default to 24 hours if no argument is provided

START_TIME=$(date -v-${HOURS}H +%Y-%m-%dT%H:%M:%SZ)
END_TIME=$(date +%Y-%m-%dT%H:%M:%SZ)

LOG_FILE="log/error_logs_$(date +%Y%m%d_%H%M%S)_${HOURS}h.json"

mkdir -p log

echo "Retrieving ERROR logs from ${START_TIME} to ${END_TIME}..."

gcloud logging read "severity=ERROR AND timestamp>=\"${START_TIME}\" AND timestamp<=\"${END_TIME}\"" \
    --project="${GOOGLE_CLOUD_PROJECT}" \
    --format=json > "${LOG_FILE}"

echo "Logs saved to ${LOG_FILE}"
