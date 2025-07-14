

init:
    uv pip install -r pyproject.toml

# list all targets
list:
    just -l

# Run tests (currently a placeholder)
test:
    echo "No tests defined yet."

# Setup a classroom environment based on a YAML configuration
# Usage: just setup-classroom etc/class_2teachers_6students.yaml
setup-classroom CLASSROOM_YAML:
    #!/usr/bin/env bash
    set -e
    echo "--- Starting Classroom Setup ---"

    # Define paths
    CLASSROOM_TF_DIR="iac/terraform/1a_classroom_setup"
    TF_VARS_FILE="${CLASSROOM_TF_DIR}/terraform.tfvars.json"
    TF_OUTPUT_FILE="iac/terraform/output/terraform_output.json"
    REPORT_FILE="iac/terraform/output/REPORT.md"

    # Step 1: Prepare Terraform variables from YAML and get the workspace name
    echo "--> Preparing Terraform variables..."
    WORKSPACE_NAME=$(/Users/ricc/git/vibecoding/bingems/.venv/bin/python ./bin/prepare_tf_vars.py \
        --classroom-yaml {{CLASSROOM_YAML}} \
        --project-config-yaml etc/project_config.yaml \
        --output-dir ${CLASSROOM_TF_DIR})

    # Step 2: Run Terraform
    echo "--> Initializing and applying Terraform in workspace: ${WORKSPACE_NAME}"
    (cd ${CLASSROOM_TF_DIR} && terraform init && terraform workspace select -or-create ${WORKSPACE_NAME} && terraform apply -auto-approve)

    # Step 3: Get Terraform output as JSON
    echo "--> Getting Terraform output..."
    (cd ${CLASSROOM_TF_DIR} && terraform output -json > ../../../${TF_OUTPUT_FILE})

    # Step 4: Generate the final report
    echo "--> Generating final report..."
    ./bin/generate_report.py \
        --tf-output-json ${TF_OUTPUT_FILE} \
        --classroom-yaml {{CLASSROOM_YAML}} \
        --report-path ${REPORT_FILE}

    echo "--- Classroom Setup Complete ---"
    echo "See ${REPORT_FILE} for details."

# Setup a sample classroom environment
setup-sample-class:
    just setup-classroom etc/class_2teachers_6students.yaml

# Teardown a classroom environment
teardown-classroom CLASSROOM_YAML:
    #!/usr/bin/env bash
    set -e
    echo "--- Starting Classroom Teardown ---"
    CLASSROOM_TF_DIR="iac/terraform/1a_classroom_setup"
    
    # Get the workspace name
    WORKSPACE_NAME=$(/Users/ricc/git/vibecoding/bingems/.venv/bin/python ./bin/prepare_tf_vars.py \
        --classroom-yaml {{CLASSROOM_YAML}} \
        --project-config-yaml etc/project_config.yaml \
        --output-dir ${CLASSROOM_TF_DIR})

    (cd ${CLASSROOM_TF_DIR} && terraform workspace select ${WORKSPACE_NAME} && terraform destroy -auto-approve)
    echo "--- Classroom Teardown Complete ---"

