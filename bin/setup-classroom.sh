#!/usr/bin/env bash
set -e

cd $(git rev-parse --show-toplevel)

CLASSROOM_YAML=$1

echo "--- Starting Classroom Setup for ${CLASSROOM_YAML} ---"

# Debugging: Print current working directory and received YAML path
echo "DEBUG: Current working directory: $(pwd)"
echo "DEBUG: CLASSROOM_YAML received: ${CLASSROOM_YAML}"

# Define paths
CLASSROOM_TF_DIR="iac/terraform/1a_classroom_setup"

# Step 1: Validate the classroom YAML
# echo "--> Validating classroom YAML..."
# just test-yaml ${CLASSROOM_YAML}

# Step 2: Prepare Terraform variables from YAML and get the workspace name
echo "--> Preparing Terraform variables..."
WORKSPACE_NAME=$(cat "${CLASSROOM_YAML}" | yq .folder.name)
echo "Workspace name: ${WORKSPACE_NAME}"

# Create dedicated directories for the classroom
CLASSROOM_VARS_ROOT_DIR="${CLASSROOM_TF_DIR}/workspaces/${WORKSPACE_NAME}"
mkdir -p ${CLASSROOM_VARS_ROOT_DIR}

# This is the absolute path where prepare_tf_vars.py will write the file
FULL_TF_VARS_PATH="${CLASSROOM_VARS_ROOT_DIR}/terraform.tfvars.json"

# This is the path relative to CLASSROOM_TF_DIR that terraform apply will use
RELATIVE_TF_VARS_PATH="workspaces/${WORKSPACE_NAME}/terraform.tfvars.json"

# Debugging: Print path passed to prepare_tf_vars.py
echo "DEBUG: Passing to prepare_tf_vars.py: ${CLASSROOM_YAML}"
uv run python ./bin/prepare_tf_vars.py --classroom-yaml "${CLASSROOM_YAML}" --project-config-yaml etc/project_config.yaml --output-file ${FULL_TF_VARS_PATH} --project-root "$(pwd)"

# Step 3: Run Terraform
echo "--> Initializing and applying Terraform in workspace: ${WORKSPACE_NAME}"
(cd ${CLASSROOM_TF_DIR} && terraform init && terraform workspace select -or-create ${WORKSPACE_NAME} && terraform apply -auto-approve -var-file=${RELATIVE_TF_VARS_PATH})

# Step 4: Get Terraform output as JSON
echo "--> Getting Terraform output..."
(cd ${CLASSROOM_TF_DIR} && terraform output -json > ../../../${TF_OUTPUT_FILE})

# Step 5: Generate the final report
echo "--> Generating final report..."
uv run ./bin/generate_report.py \
    --tf-output-json ${TF_OUTPUT_FILE} \
    --classroom-yaml ${CLASSROOM_YAML} \
    --report-path ${REPORT_FILE}

echo "--- Classroom Setup Complete ---"
echo "See ${REPORT_FILE} for details."
