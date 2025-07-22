#!/bin/bash
#
# Sets up the complete initial environment for the SaaS Runtime demo.
#

set -euo pipefail

# Source the environment variables
source .envrc
if [ -f .env.post ]; then
    source .envrc.post
fi

echo "Setting gcloud project and identity..."
gcloud config set project "${GOOGLE_CLOUD_PROJECT}"
gcloud config set account "${GOOGLE_IDENTITY}"


echo "Enabling all required Google Cloud APIs..."
gcloud services enable \
    saasservicemgmt.googleapis.com \
    artifactregistry.googleapis.com \
    config.googleapis.com \
    developerconnect.googleapis.com \
    cloudbuild.googleapis.com \
    storage.googleapis.com \
    iam.googleapis.com \
    --project="${GOOGLE_CLOUD_PROJECT}"


echo "Granting required permissions to SaaS Runtime service account..."

# Grant roles one by one to ensure clarity and idempotency
ROLES=(
    "roles/artifactregistry.admin"
    "roles/storage.admin"
    "roles/config.admin"
    "roles/iam.serviceAccountShortTermTokenMinter"
    "roles/iam.serviceAccountUser"
    "roles/owner" # From previous steps, keeping for safety
)

for ROLE in "${ROLES[@]}"; do
    echo "Ensuring role [${ROLE}] for SA [${SAAS_SERVICE_ACCOUNT}]..."
    gcloud projects add-iam-policy-binding "${GOOGLE_CLOUD_PROJECT}" \
        --member="serviceAccount:${SAAS_SERVICE_ACCOUNT}" \
        --role="${ROLE}" \
        --condition=None > /dev/null # Suppress verbose output
done

echo "Environment setup complete."