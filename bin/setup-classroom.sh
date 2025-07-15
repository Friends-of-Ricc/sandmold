#!/usr/bin/env bash
set -e

# cd to the root of the git repository
cd $(git rev-parse --show-toplevel)

CLASSROOM_YAML="$1"
CLASSROOM_TF_DIR="$2" # New argument

if [ -z "$CLASSROOM_TF_DIR" ]; then
    echo "Error: Terraform directory not provided. Usage: $0 <classroom_yaml> <terraform_dir>"
    exit 1
fi

echo "--- Starting Classroom Setup for ${CLASSROOM_YAML} in ${CLASSROOM_TF_DIR} ---"

# Debugging info
echo "DEBUG: Current working directory: $(pwd)"
echo "DEBUG: CLASSROOM_YAML received: ${CLASSROOM_YAML}"
echo "DEBUG: CLASSROOM_TF_DIR received: ${CLASSROOM_TF_DIR}"

# Define output file paths, now inside the TF directory
TF_OUTPUT_FILE="${CLASSROOM_TF_DIR}/terraform_output.json"
REPORT_FILE="${CLASSROOM_TF_DIR}/REPORT.md"
FULL_TF_VARS_PATH="${CLASSROOM_TF_DIR}/terraform.tfvars.json"

# Step 1: (omitted)

# Step 2: Prepare Terraform variables
echo "--> Preparing Terraform variables..."
WORKSPACE_NAME=$(cat "${CLASSROOM_YAML}" | yq -r .metadata.name)
echo "Workspace name: ${WORKSPACE_NAME}"

# No longer creating a 'workspaces' subdirectory.
# prepare_tf_vars.py will write directly to FULL_TF_VARS_PATH.
echo "DEBUG: Writing tfvars to: ${FULL_TF_VARS_PATH}"
uv run python ./bin/prepare_tf_vars.py --classroom-yaml "${CLASSROOM_YAML}" --project-config-yaml etc/project_config.yaml --output-file "${FULL_TF_VARS_PATH}" --project-root "$(pwd)"

# Step 3: Run Terraform
echo "--> Initializing and applying Terraform in workspace: ${WORKSPACE_NAME}"
# The -var-file path is now simpler, relative to CLASSROOM_TF_DIR
(cd "${CLASSROOM_TF_DIR}" && terraform init && terraform workspace select -or-create "${WORKSPACE_NAME}" && terraform apply -auto-approve -var-file="terraform.tfvars.json")

# Step 4: Get Terraform output as JSON
echo "--> Getting Terraform output..."
# Output is now redirected to the file inside CLASSROOM_TF_DIR
(cd "${CLASSROOM_TF_DIR}" && terraform output -json > "terraform_output.json")

# Step 5: Generate the final report
echo "--> Generating final report..."
# The script now reads from and writes to files inside CLASSROOM_TF_DIR
uv run ./bin/generate_report.py 
    --tf-output-json "${TF_OUTPUT_FILE}" 
    --classroom-yaml "${CLASSROOM_YAML}" 
    --report-path "${REPORT_FILE}"

echo "--- Classroom Setup Complete ---"
echo "See ${REPORT_FILE} for details."
