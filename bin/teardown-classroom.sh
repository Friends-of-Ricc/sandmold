#!/usr/bin/env bash
set -e

CLASSROOM_YAML=$1

echo "--- Starting Classroom Teardown for ${CLASSROOM_YAML} ---"

CLASSROOM_TF_DIR="iac/terraform/1a_classroom_setup"

# Get the workspace name
WORKSPACE_NAME=$(cat "${CLASSROOM_YAML}" | yq .folder.name)

# Create dedicated directories for the classroom
CLASSROOM_VARS_ROOT_DIR="${CLASSROOM_TF_DIR}/workspaces/${WORKSPACE_NAME}"

# This is the path relative to CLASSROOM_TF_DIR that terraform destroy will use
RELATIVE_TF_VARS_PATH="workspaces/${WORKSPACE_NAME}/terraform.tfvars.json"

(cd ${CLASSROOM_TF_DIR} && terraform workspace select ${WORKSPACE_NAME} && terraform destroy -auto-approve -var-file=${RELATIVE_TF_VARS_PATH})

echo "--- Classroom Teardown Complete ---"
