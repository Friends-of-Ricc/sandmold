#!/bin/bash
#
# Orchestrates the deployment and cleanup of a SaaS Offering based on a SUkUR YAML file.
#

set -euo pipefail

source "$(dirname "$0")/common-setup.sh"

if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# --- Argument Check ---
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <SUKUR_YAML_FILE>"
    exit 1
fi

SUKUR_YAML_FILE="$1"

# --- Extract parameters from SUkUR YAML ---
SAAS_NAME=$(yq '.spec.saas_name' "${SUKUR_YAML_FILE}")
UNIT_KIND_NAME=$(yq '.spec.unit_kind_name' "${SUKUR_YAML_FILE}")
RELEASE_NAME=$(yq '.spec.release_name' "${SUKUR_YAML_FILE}")
TERRAFORM_MODULE_DIR=$(yq '.spec.terraform_module_dir' "${SUKUR_YAML_FILE}")
INSTANCE_NAME=$(yq '.spec.instance_name' "${SUKUR_YAML_FILE}")
ROLLOUT_KIND_NAME=$(yq '.spec.rollout_kind_name' "${SUKUR_YAML_FILE}")
ROLLOUT_NAME=$(yq '.spec.rollout_name' "${SUKUR_YAML_FILE}")

# --- Cleanup Steps ---
echo "🧹 Cleaning up previous deployment for ${SAAS_NAME} (if any)..."

# 1. Deprovision and delete Units
UNIT_LIST=$(gcloud beta saas-runtime units list --filter="name~${INSTANCE_NAME}" --format="value(name)" --project="${GOOGLE_CLOUD_PROJECT}" --location="${GOOGLE_CLOUD_REGION}")
if [ -n "${UNIT_LIST}" ]; then
    for UNIT in ${UNIT_LIST}; do
        echo "Deprovisioning unit: ${UNIT}"
        bin/08-deprovision-unit.sh --unit-name "${UNIT##*/}"
        sleep 30
        echo "Deleting unit: ${UNIT}"
        gcloud beta saas-runtime units delete "${UNIT##*/}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" --quiet
    done
fi

# 2. Update Unit Kind to clear default release, then delete Releases and Unit Kinds
UNIT_KIND_FULL_NAME="projects/${GOOGLE_CLOUD_PROJECT}/locations/${GOOGLE_CLOUD_REGION}/unitKinds/${UNIT_KIND_NAME}"
if gcloud beta saas-runtime unit-kinds describe "${UNIT_KIND_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    # Unset default release
    echo "Unsetting default release for Unit Kind: ${UNIT_KIND_NAME}"
    gcloud beta saas-runtime unit-kinds update "${UNIT_KIND_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" --default-release="" --quiet
    sleep 10 # Give the API time to process the update

    # Delete Releases associated with this Unit Kind
    RELEASE_LIST=$(gcloud beta saas-runtime releases list --filter="unitKind=${UNIT_KIND_FULL_NAME}" --format="value(name)" --project="${GOOGLE_CLOUD_PROJECT}" --location="${GOOGLE_CLOUD_REGION}")
    if [ -n "${RELEASE_LIST}" ]; then
        for RELEASE in ${RELEASE_LIST}; do
            echo "Deleting release: ${RELEASE}"
            gcloud beta saas-runtime releases delete "${RELEASE##*/}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" --quiet
        done
    fi

    # Delete Unit Kind
    echo "Deleting Unit Kind: ${UNIT_KIND_NAME}"
    gcloud beta saas-runtime unit-kinds delete "${UNIT_KIND_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" --quiet
fi

# 3. Delete SaaS Instance
if gcloud beta saas-runtime saas describe "${SAAS_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Deleting SaaS Instance: ${SAAS_NAME}"
    gcloud beta saas-runtime saas delete "${SAAS_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" --quiet
fi


# --- Deployment Steps ---
echo "🚀 Deploying SUkUR: ${SAAS_NAME}"

# STEP 1: Create SaaS Offering
bin/01-create-saas.sh --saas-name "${SAAS_NAME}"

# STEP 2: Create Unit Kind
bin/02-create-unit-kind.sh --unit-kind-name "${UNIT_KIND_NAME}" --saas-name "${SAAS_NAME}"

# STEP 3: Build and Push Blueprint
bin/03-build-and-push-blueprint.sh --terraform-module-dir "${TERRAFORM_MODULE_DIR}"

# STEP 4: Create Release
FULL_RELEASE_NAME=$(bin/04-create-release.sh --release-name "${RELEASE_NAME}" --unit-kind-name "${UNIT_KIND_NAME}" --terraform-module-dir "${TERRAFORM_MODULE_DIR}")
echo "${FULL_RELEASE_NAME}" > /tmp/current_full_release_name.txt

# STEP 5: Reposition Unit Kind Default
bin/04a-reposition-uk-default.sh --unit-kind-name "${UNIT_KIND_NAME}" --release-name "${FULL_RELEASE_NAME##*/}"

# STEP 6: Create Unit
bin/05-create-unit.sh --instance-name "${INSTANCE_NAME}" --unit-kind-name "${UNIT_KIND_NAME}"

# STEP 7: Provision Unit
bin/06-provision-unit.sh --unit-name "${INSTANCE_NAME}" --release-name "${FULL_RELEASE_NAME##*/}"

# STEP 8: Create Rollout Kind and Rollout
bin/07-create-rollout.sh --unit-kind-name "${UNIT_KIND_NAME}" --release-name "${FULL_RELEASE_NAME##*/}" --rollout-kind-name "${ROLLOUT_KIND_NAME}" --rollout-name "${ROLLOUT_NAME}"

echo "✅ SUkUR deployment for ${SAAS_NAME} complete."