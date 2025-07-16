#!/usr/bin/env bash
set -e
set -o pipefail

# cd to the root of the git repository
cd "$(git rev-parse --show-toplevel)"

CLASSROOM_YAML="$1"
CLASSROOM_TF_DIR="$2" # New argument

if [ -z "$CLASSROOM_TF_DIR" ]; then
    echo "Error: Terraform directory not provided. Usage: $0 <classroom_yaml> <terraform_dir>"
    exit 1
fi

echo "--- Starting Classroom Setup for ${CLASSROOM_YAML} in ${CLASSROOM_TF_DIR} ---"

# --- Step 1: Define all paths based on workspace ---
WORKSPACE_NAME=$(cat "${CLASSROOM_YAML}" | yq -r .metadata.name)
echo "Workspace name: ${WORKSPACE_NAME}"

CLASSROOM_WORKSPACE_DIR="${CLASSROOM_TF_DIR}/workspaces/${WORKSPACE_NAME}"
mkdir -p "${CLASSROOM_WORKSPACE_DIR}"

# Define absolute paths for all artifacts
TF_VARS_FILE="$(pwd)/${CLASSROOM_WORKSPACE_DIR}/terraform.tfvars.json"
TF_OUTPUT_FILE="$(pwd)/${CLASSROOM_WORKSPACE_DIR}/terraform_output.json"
REPORT_FILE="$(pwd)/${CLASSROOM_WORKSPACE_DIR}/REPORT.md"
# New timestamped log file
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")
APPLY_LOG_FILE="$(pwd)/${CLASSROOM_WORKSPACE_DIR}/${TIMESTAMP}_apply.log"

echo "DEBUG: All artifacts will be stored in: ${CLASSROOM_WORKSPACE_DIR}"
echo "DEBUG: Terraform logs will be saved to: ${APPLY_LOG_FILE}"

# --- Step 2: Prepare Terraform variables ---
echo "--> Preparing Terraform variables..."
uv run python ./bin/prepare_tf_vars.py \
    --classroom-yaml "${CLASSROOM_YAML}" \
    --project-config-yaml etc/project_config.yaml \
    --output-file "${TF_VARS_FILE}" \
    --project-root "$(pwd)"

# --- Step 3: Run Terraform, teeing output to a log file ---
echo "--> Initializing and applying Terraform in workspace: ${WORKSPACE_NAME}"

# Calculate the relative path for the tfvars file from the terraform directory
RELATIVE_TF_VARS_FILE="workspaces/${WORKSPACE_NAME}/terraform.tfvars.json"

# The -var-file path is now relative to the CLASSROOM_TF_DIR
(cd "${CLASSROOM_TF_DIR}" && 
    terraform init && 
    terraform workspace select -or-create "${WORKSPACE_NAME}" && 
    terraform apply -auto-approve -var-file="${RELATIVE_TF_VARS_FILE}") 2>&1 | tee "${APPLY_LOG_FILE}"

# --- Step 4: Get Terraform output as JSON ---
echo "--> Getting Terraform output..."
(cd "${CLASSROOM_TF_DIR}" && terraform output -json > "${TF_OUTPUT_FILE}")

# --- Step 5: Generate the final report ---
echo "--> Generating final report..."
uv run ./bin/generate_report.py \
    --tf-output-json "${TF_OUTPUT_FILE}" \
    --classroom-yaml "${CLASSROOM_YAML}" \
    --report-path "${REPORT_FILE}"

echo "--- Classroom Setup Complete ---"
echo "See ${REPORT_FILE} for details."
