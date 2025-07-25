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
#UNIT_KIND_REF=$(yq '.spec.unit_kind_ref' "${SUKUR_YAML_FILE}")
#UNIT_KIND_DEFINITION_JSON=$(yq -o=json ".unit_kinds.${UNIT_KIND_REF}" etc/unit-kinds.yaml)
#UNIT_KIND_NAME=$(echo "${UNIT_KIND_DEFINITION_JSON}" | jq -r '.name')
UNIT_KIND_REF=$(yq '.spec.unit_kind_ref' "${SUKUR_YAML_FILE}")
UNIT_KIND_DEFINITION_JSON=$(yq -o=json ".unit_kinds.${UNIT_KIND_REF}" etc/unit-kinds.yaml)
UNIT_KIND_NAME=$(echo "${UNIT_KIND_DEFINITION_JSON}" | jq -r '.name')
RELEASE_NAME=$(yq '.spec.release_name' "${SUKUR_YAML_FILE}")
TERRAFORM_MODULE_DIR=$(yq '.spec.terraform_module_dir' "${SUKUR_YAML_FILE}")
INSTANCE_NAME=$(yq '.spec.instance_name' "${SUKUR_YAML_FILE}")

# Extract input variables as a JSON string
INPUT_VARIABLES_JSON=$(yq '.spec.input_variables | to_json' "${SUKUR_YAML_FILE}")


( # Start best-effort cleanup subshell

# --- Cleanup Steps ---
echo "🧹 Cleaning up previous deployment for ${SAAS_NAME} (if any)..."

# --- Cleanup Steps (best effort) ---
echo "🧹 Attempting best-effort cleanup for ${SAAS_NAME} (if any)..."

# Attempt to unset default release for Unit Kind
UNIT_KIND_FULL_NAME="projects/${GOOGLE_CLOUD_PROJECT}/locations/${GOOGLE_CLOUD_REGION}/unitKinds/${UNIT_KIND_NAME}"
if gcloud beta saas-runtime unit-kinds describe "${UNIT_KIND_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" &> /dev/null; then
    echo "Attempting to unset default release for Unit Kind: ${UNIT_KIND_NAME}"
    gcloud beta saas-runtime unit-kinds update "${UNIT_KIND_NAME}" --location="${GOOGLE_CLOUD_REGION}" --project="${GOOGLE_CLOUD_PROJECT}" --default-release="" --quiet || true
fi

) || true # End best-effort cleanup subshell


# --- Deployment Steps ---
echo "🚀 Deploying SUkUR: ${SAAS_NAME}"

# STEP 1: Create SaaS Offering
bin/01-create-saas.sh --saas-name "${SAAS_NAME}"

UNIT_KIND_DEFINITION_JSON=$(yq ".unit_kinds.${UNIT_KIND_REF}" etc/unit-kinds.yaml | to_json)

# STEP 2: Create Unit Kind
bin/02-create-unit-kind.sh --unit-kind-definition-json "${UNIT_KIND_DEFINITION_JSON}"

# STEP 3: Build and Push Blueprint
bin/03-build-and-push-blueprint.sh --terraform-module-dir "${TERRAFORM_MODULE_DIR}"

# STEP 4: Create Release
FULL_RELEASE_NAME=$(bin/04-create-release.sh --release-name "${RELEASE_NAME}" --unit-kind-name "${UNIT_KIND_NAME}" --terraform-module-dir "${TERRAFORM_MODULE_DIR}" --input-variables-json "${INPUT_VARIABLES_JSON}")

# STEP 5: Reposition Unit Kind Default
bin/04a-reposition-uk-default.sh --unit-kind-name "${UNIT_KIND_NAME}" --release-name "${FULL_RELEASE_NAME##*/}"

# STEP 6: Create Unit
bin/05-create-unit.sh --instance-name "${INSTANCE_NAME}" --unit-kind-name "${UNIT_KIND_NAME}"

# STEP 7: Provision Unit
bin/06-provision-unit.sh --unit-name "${INSTANCE_NAME}" --release-name "${FULL_RELEASE_NAME##*/}" --input-variables-json "${INPUT_VARIABLES_JSON}"



echo "✅ SUkUR deployment for ${SAAS_NAME} complete."
