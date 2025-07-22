#!/bin/bash
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
