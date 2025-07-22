#!/bin/bash
#
# Reads Cloud Audit Logs for errors and writes them to a file.
#

set -euo pipefail

source .env

LOG_FILE="log/audit_logs_$(date +%Y%m%d_%H%M%S).json"

TIMESTAMP_5_MIN_AGO=$(date -u -v-5M +%Y-%m-%dT%H:%M:%SZ)

echo "Reading Cloud Audit Logs and writing to ${LOG_FILE}"
gcloud logging read 'resource.type=("saas_service_management.googleapis.com" OR "gcs_bucket" OR "cloud_build") AND severity>="ERROR"' --project="${GOOGLE_CLOUD_PROJECT}" --limit=100 --format=json | jq --arg ts "${TIMESTAMP_5_MIN_AGO}" '.[] | select(.timestamp > $ts)' > "${LOG_FILE}"

echo "Audit logs saved to ${LOG_FILE}"
