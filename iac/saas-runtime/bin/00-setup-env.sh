#!/bin/bash
#
# Sets up the complete initial environment for the SaaS Runtime demo.
#

set -euo pipefail
set -x

source "$(dirname "$0")/common-setup.sh"

# --- Create and configure GCS bucket for Terraform blueprints ---
#TF_BLUEPRINT_BUCKET="sandmold-tf-blueprints-${GOOGLE_CLOUD_PROJECT}"

export TF_BLUEPRINT_BUCKET
#echo "TF_BLUEPRINT_BUCKET=${TF_BLUEPRINT_BUCKET}" >> .env.auto

echo "SAAS_SERVICE_ACCOUNT: ${SAAS_SERVICE_ACCOUNT}"

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

# --- Create and configure Terraform Actuator Service Account ---
TF_ACTUATOR_SA_NAME="sandmold-tf-actuator"
TF_ACTUATOR_SA_EMAIL="${TF_ACTUATOR_SA_NAME}@${GOOGLE_CLOUD_PROJECT}.iam.gserviceaccount.com"

echo "Creating Terraform Actuator Service Account: ${TF_ACTUATOR_SA_EMAIL}..."
if ! gcloud iam service-accounts describe "${TF_ACTUATOR_SA_EMAIL}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    gcloud iam service-accounts create "${TF_ACTUATOR_SA_NAME}" \
        --display-name="Sandmold Terraform Actuator" \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Service Account ${TF_ACTUATOR_SA_EMAIL} already exists."
fi

echo "Granting permissions to Terraform Actuator Service Account..."
TF_ACTUATOR_ROLES=(
    "roles/editor"
    "roles/storage.admin"
    "roles/config.agent"
)

# roles/config.agent comews from duckie

for ROLE in "${TF_ACTUATOR_ROLES[@]}"; do
    echo "Ensuring role [${ROLE}] for SA [${TF_ACTUATOR_SA_EMAIL}]..."
    gcloud projects add-iam-policy-binding "${GOOGLE_CLOUD_PROJECT}" \
        --member="serviceAccount:${TF_ACTUATOR_SA_EMAIL}" \
        --role="${ROLE}" \
        --condition=None > /dev/null
done

echo "Creating GCS bucket for Terraform blueprints: gs://${TF_BLUEPRINT_BUCKET}"
echo "GOOGLE_CLOUD_PROJECT: ${GOOGLE_CLOUD_PROJECT}"
echo "GOOGLE_IDENTITY: ${GOOGLE_IDENTITY}"
if ! gsutil ls "gs://${TF_BLUEPRINT_BUCKET}" &> /dev/null; then
    gsutil mb -p "${GOOGLE_CLOUD_PROJECT}" -l "${GOOGLE_CLOUD_REGION}" --versioning-enabled "gs://${TF_BLUEPRINT_BUCKET}"
else
    echo "GCS bucket gs://${TF_BLUEPRINT_BUCKET} already exists."
fi

echo "Granting storage.objectAdmin to ${TF_ACTUATOR_SA_EMAIL} on gs://${TF_BLUEPRINT_BUCKET}"
gsutil iam ch "serviceAccount:${TF_ACTUATOR_SA_EMAIL}:objectAdmin" "gs://${TF_BLUEPRINT_BUCKET}"

# --- Create Artifact Registry ---
echo "Creating Artifact Registry: ${ARTIFACT_REGISTRY_NAME} in ${GOOGLE_CLOUD_REGION}"
if ! gcloud artifacts repositories describe "${ARTIFACT_REGISTRY_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    gcloud artifacts repositories create "${ARTIFACT_REGISTRY_NAME}" \
        --repository-format=docker \
        --location="${GOOGLE_CLOUD_REGION}" \
        --description="Docker repository for SaaS Runtime blueprints" \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Artifact Registry ${ARTIFACT_REGISTRY_NAME} already exists."
fi



echo "Environment setup complete."
