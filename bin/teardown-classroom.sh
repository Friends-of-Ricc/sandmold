#!/usr/bin/env bash
set -e

CLASSROOM_YAML="$1"
CLASSROOM_TF_DIR="$2"

if [ -z "$CLASSROOM_TF_DIR" ]; then
    echo "Error: Terraform directory not provided. Usage: $0 <classroom_yaml> <terraform_dir>"
    exit 1
fi

echo "--- Starting Classroom Teardown for ${CLASSROOM_YAML} in ${CLASSROOM_TF_DIR} ---"

# Get the workspace name from the new schema
WORKSPACE_NAME=$(cat "${CLASSROOM_YAML}" | yq -r .metadata.name)

# The tfvars file is now in the root of the TF directory
TF_VARS_FILE="terraform.tfvars.json"

(cd "${CLASSROOM_TF_DIR}" && terraform workspace select "${WORKSPACE_NAME}" && terraform destroy -auto-approve -var-file="${TF_VARS_FILE}")

echo "--- Classroom Teardown Complete ---"
