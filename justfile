
# list all targets. This should be the first target in the file and DEFAULT
list:
    just -l


init:
    uv pip install -r pyproject.toml

# Run tests (currently a placeholder)
test:
    #echo "No tests defined yet."
    just test-yaml etc/class_2teachers_6students.yaml
    just test-yaml etc/class_2teachers_4realstudents.yaml

# Test a classroom YAML file for common errors
test-yaml CLASSROOM_YAML:
    /Users/ricc/git/vibecoding/bingems/.venv/bin/python ./tests/test_yaml_validation.py --classroom-yaml {{shell_quote(absolute_path(CLASSROOM_YAML))}}

# Setup a classroom environment based on a YAML configuration
# Usage: just setup-classroom etc/class_2teachers_6students.yaml
setup-classroom CLASSROOM_YAML:
    #!/usr/bin/env bash
    set -e
    echo "--- Starting Classroom Setup ---"

    # Define paths
    CLASSROOM_TF_DIR="iac/terraform/1a_classroom_setup"

    # Step 1: Validate the classroom YAML
    echo "--> Validating classroom YAML..."
    just test-yaml {{CLASSROOM_YAML}}

    # Step 2: Prepare Terraform variables from YAML and get the workspace name
    echo "--> Preparing Terraform variables..."
    WORKSPACE_NAME=$(/Users/ricc/git/vibecoding/bingems/.venv/bin/python ./bin/prepare_tf_vars.py --classroom-yaml {{CLASSROOM_YAML}} --project-config-yaml etc/project_config.yaml)
    echo "Workspace name: ${WORKSPACE_NAME}"

    # Create dedicated directories for the classroom
    CLASSROOM_VARS_DIR="${CLASSROOM_TF_DIR}/workspaces/${WORKSPACE_NAME}"
    mkdir -p ${CLASSROOM_VARS_DIR}
    TF_VARS_FILE="${CLASSROOM_VARS_DIR}/terraform.tfvars.json"

    TF_OUTPUT_DIR="iac/terraform/output/${WORKSPACE_NAME}"
    mkdir -p ${TF_OUTPUT_DIR}
    TF_OUTPUT_FILE="${TF_OUTPUT_DIR}/terraform_output.json"
    REPORT_FILE="${TF_OUTPUT_DIR}/REPORT.md"

    # Regenerate the vars file in the correct location
    /Users/ricc/git/vibecoding/bingems/.venv/bin/python ./bin/prepare_tf_vars.py --classroom-yaml {{CLASSROOM_YAML}} --project-config-yaml etc/project_config.yaml --output-file ${TF_VARS_FILE}

    # Step 3: Run Terraform
    echo "--> Initializing and applying Terraform in workspace: ${WORKSPACE_NAME}"
    (cd ${CLASSROOM_TF_DIR} && terraform init && terraform workspace select -or-create ${WORKSPACE_NAME} && terraform apply -auto-approve -var-file=${TF_VARS_FILE})

    # Step 4: Get Terraform output as JSON
    echo "--> Getting Terraform output..."
    (cd ${CLASSROOM_TF_DIR} && terraform output -json > ../../../${TF_OUTPUT_FILE})

    # Step 5: Generate the final report
    echo "--> Generating final report..."
    /Users/ricc/git/vibecoding/bingems/.venv/bin/python ./bin/generate_report.py \
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
    WORKSPACE_NAME=$(/Users/ricc/git/vibecoding/bingems/.venv/bin/python ./bin/prepare_tf_vars.py --classroom-yaml {{CLASSROOM_YAML}} --project-config-yaml etc/project_config.yaml)

    (cd ${CLASSROOM_TF_DIR} && terraform workspace select ${WORKSPACE_NAME} && terraform destroy -auto-approve)
    echo "--- Classroom Teardown Complete ---"

