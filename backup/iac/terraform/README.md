# Sandmold Terraform Infrastructure

This directory contains all the Terraform code for provisioning Google Cloud resources for the Sandmold project.

## Architecture

The infrastructure is designed to be modular, reusable, and support two primary use cases (CUJs), as defined in the main `REQUIREMENTS.md`. The core of the architecture is the `modules/project` module, which is the single source of truth for creating and configuring a standard GCP project.

A detailed breakdown of the module and configuration interfaces can be found in `doc/TF_INTERFACES.md`.

## Workflows

There are two distinct workflows for provisioning resources.

### 1. Classroom Setup (CUJ001)

This workflow is for instructors who want to pre-provision a Google Cloud Folder and a set of projects for a classroom of students.

*   **Configuration**: `1a_classroom_setup/`
*   **Entrypoint**: The master `setup.sh` script (or `just` command) in the root of the repository.
*   **Process**:
    1.  The user populates a classroom YAML file (e.g., `etc/class_2teachers_6students.yaml`).
    2.  The `setup.sh` script calls `bin/prepare_tf_vars.py` to generate the necessary `terraform.tfvars.json`.
    3.  The script runs `terraform apply` within the `1a_classroom_setup` directory.
    4.  The script calls `bin/generate_report.py` to create a final `REPORT.md`.

### 2. Single User Setup (CUJ002)

This workflow is for individual users who want to provision a single project in their own account ("Bring Your Own Identity").

*   **Configuration**: `1b_single_user_setup/`
*   **Instructions**: See the `README.md` within that directory for detailed, user-friendly instructions.
*   **Process**:
    1.  The user creates a `terraform.tfvars` file with their specific details (project ID, billing account, etc.).
    2.  The user runs `terraform init` and `terraform apply` directly from the `1b_single_user_setup` directory.

### 3. Application Deployment

After either of the above setup workflows are complete, the `2_apps_deployment` configuration can be run to install applications on the newly created projects.

*   **Configuration**: `2_apps_deployment/`
*   **Status**: This stage is currently a placeholder. See the `README.md` in that directory for the future implementation plan.
