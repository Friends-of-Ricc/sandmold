#!/bin/bash
#
# Orchestrates the deployment and cleanup of a SaaS Offering based on a SUkUR YAML file.
#
# This script generates a temporary deployment script and instructs the user to execute it.
# This decouples the script generation from its execution, allowing for easier debugging.
#

set -euo pipefail

source "$(dirname "$0")/common-setup.sh"

if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# --- Argument Check ---
OUTPUT_SCRIPT_PATH="tmp/generated_deployment_script.sh"
SUKUR_YAML_FILE=""
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --output-script-path)
            OUTPUT_SCRIPT_PATH="$2"
            shift 2
            ;;
        *)
            SUKUR_YAML_FILE="$1"
            shift
            ;;
    esac
done

if [ -z "${SUKUR_YAML_FILE}" ]; then
    echo "Usage: $0 <SUKUR_YAML_FILE> [--output-script-path <PATH>]"
    exit 1
fi

GENERATED_SCRIPT="${OUTPUT_SCRIPT_PATH}"
mkdir -p "$(dirname "${GENERATED_SCRIPT}")"

# --- Extract parameters from SUkUR YAML ---
SAAS_NAME=$(yq '.spec.saas_name' "${SUKUR_YAML_FILE}")
UNIT_KIND_NAME=$(yq '.spec.unit_kind_name' "${SUKUR_YAML_FILE}")
RELEASE_NAME=$(yq '.spec.release_name' "${SUKUR_YAML_FILE}")
TERRAFORM_MODULE_DIR=$(yq '.spec.terraform_module_dir' "${SUKUR_YAML_FILE}")
INSTANCE_NAME=$(yq '.spec.instance_name' "${SUKUR_YAML_FILE}")

# Extract input variables as a JSON string
INPUT_VARIABLES_JSON=$(yq -o=json '.spec.input_variables' "${SUKUR_YAML_FILE}")


( # Start best-effort cleanup subshell
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
echo "🚀 Generating deployment script for SUkUR: ${SAAS_NAME}"

# Write deployment steps to the generated script
cat <<EOF > "${GENERATED_SCRIPT}"
#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/common-setup.sh"

if [ "${SAAS_DEBUG:-false}" == "true" ]; then
    set -x
fi

# --- Deployment Steps for ${SAAS_NAME} ---

# STEP 1: Create SaaS Offering
bin/01-create-saas.sh --saas-name "${SAAS_NAME}"

# STEP 2: Create Unit Kind
bin/02-create-unit-kind.sh --unit-kind-name "${UNIT_KIND_NAME}" --saas-name "${SAAS_NAME}"

# STEP 3: Build and Push Blueprint
bin/03-build-and-push-blueprint.sh --terraform-module-dir "${TERRAFORM_MODULE_DIR}"

# STEP 4: Create Release
FULL_RELEASE_NAME=\$(bin/04-create-release.sh --release-name "${RELEASE_NAME}" --unit-kind-name "${UNIT_KIND_NAME}" --terraform-module-dir "${TERRAFORM_MODULE_DIR}" --input-variables-json "${INPUT_VARIABLES_JSON}")

# STEP 5: Reposition Unit Kind Default
bin/04a-reposition-uk-default.sh --unit-kind-name "${UNIT_KIND_NAME}" --release-name "\${FULL_RELEASE_NAME##*/}"

# STEP 6: Create Unit
bin/05-create-unit.sh --instance-name "${INSTANCE_NAME}" --unit-kind-name "${UNIT_KIND_NAME}"

# STEP 7: Provision Unit
bin/06-provision-unit.sh --unit-name "${INSTANCE_NAME}" --release-name "\${FULL_RELEASE_NAME##*/}" --input-variables-json "${INPUT_VARIABLES_JSON}"

echo "✅ SUkUR deployment for ${SAAS_NAME} complete."
EOF

chmod +x "${GENERATED_SCRIPT}"

echo "Generated deployment script: ${GENERATED_SCRIPT}"
echo "Please inspect the script and execute it manually to perform the deployment."
