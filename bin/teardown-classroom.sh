#!/usr/bin/env bash
set -e

CLASSROOM_YAML=$1

echo "--- Starting Classroom Teardown for ${CLASSROOM_YAML} ---"

CLASSROOM_TF_DIR="iac/terraform/1a_classroom_setup"

# Get the workspace name
WORKSPACE_NAME=$(cat ${CLASSROOM_YAML} | yq .folder.name)

(cd ${CLASSROOM_TF_DIR} && terraform workspace select ${WORKSPACE_NAME} && terraform destroy -auto-approve)

echo "--- Classroom Teardown Complete ---"
