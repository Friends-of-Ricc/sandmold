#!/bin/bash
#
# Creates a Rollout Kind and a Rollout to trigger Unit provisioning.
# TODO(ricc): This will probably fail as we've refactored UNIT_KIND_NAME_GLOBAL as "${UNIT_KIND_NAME_BASE}-global"
# Please amend that!

set -euo pipefail

# Source the environment variables
source .env

# --- Configuration ---
ROLLOUT_KIND_NAME="default-rollout-kind"
ROLLOUT_NAME="initial-rollout"
#UNIT_KIND_GLOBAL="${UNIT_KIND_NAME_BASE}-global"

# --- Create Rollout Kind ---
echo "Checking for Rollout Kind '${ROLLOUT_KIND_NAME}'..."
if ! gcloud beta saas-runtime rollout-kinds describe "${ROLLOUT_KIND_NAME}" \
    --unit-kind="${UNIT_KIND_NAME_GLOBAL}" \
    --location=global \
    --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then

    echo "Creating Rollout Kind '${ROLLOUT_KIND_NAME}' for Unit Kind '${UNIT_KIND_NAME_GLOBAL}'..."
    gcloud beta saas-runtime rollout-kinds create "${ROLLOUT_KIND_NAME}" \
        --unit-kind="${UNIT_KIND_NAME_GLOBAL}" \
        --location=global \
        --rollout-orchestration-strategy="Google.Cloud.Simple.AllAtOnce" \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Rollout Kind '${ROLLOUT_KIND_NAME}' already exists."
fi

# --- Create Rollout ---
echo "Checking for Rollout '${ROLLOUT_NAME}'..."
if ! gcloud beta saas-runtime rollouts describe "${ROLLOUT_NAME}" \
    --rollout-kind="${ROLLOUT_KIND_NAME}" \
    --location=global \
    --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then

    echo "Creating Rollout '${ROLLOUT_NAME}' for Release '${RELEASE_NAME}' and Rollout Kind '${ROLLOUT_KIND_NAME}'..."
    gcloud beta saas-runtime rollouts create "${ROLLOUT_NAME}" \
        --release="${RELEASE_NAME}" \
        --rollout-kind="${ROLLOUT_KIND_NAME}" \
        --location=global \
        --project="${GOOGLE_CLOUD_PROJECT}"
else
    echo "Rollout '${ROLLOUT_NAME}' already exists."
fi

echo "Rollout setup complete."
