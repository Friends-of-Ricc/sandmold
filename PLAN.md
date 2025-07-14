### Plan: Multi-Stage Terraform Project Setup

This plan outlines the steps to create a multi-stage Terraform configuration for provisioning Google Cloud projects based on a YAML configuration file.

- [ ] **Phase 1: Scaffolding & Configuration Processing**
    - [ ] Create the directory structure under `iac/terraform/` mirroring the `vendor/genai-factory/cloud-run-single` model (`0_projects`, `1_apps`).
    - [ ] Create a `project_config.yaml` in `etc/` to define APIs and IAM roles, inspired by `genai-factory`.
    - [ ] Create a Python script (`bin/generate_tf_vars.py`) that parses both `etc/class_2teachers_6students.yaml` and `etc/project_config.yaml` and generates a `terraform.tfvars.json` file for the `0_projects` stage.

- [ ] **Phase 2: Terraform Project Creation (`0_projects`)**
    - [ ] In `iac/terraform/0_projects/variables.tf`, define variables to accept the structured data from the generated `terraform.tfvars.json` (e.g., a list of project objects, APIs to enable, and IAM roles to grant).
    - [ ] In `iac/terraform/0_projects/main.tf`, implement the core logic:
        - [ ] Use the `random_string` resource to generate a 4-character hex suffix for each project ID to ensure uniqueness.
        - [ ] Use a `for_each` loop over the list of projects to create a `google_project` resource for each `schoolbench`.
        - [ ] For each created project, use a `for_each` loop to enable the APIs defined in `project_config.yaml` using the `google_project_service` resource.
        - [ ] For each created project, use nested `for_each` loops to iterate through the `seats` and the roles defined in `project_config.yaml`, creating `google_project_iam_member` resources to grant the specified permissions.
    - [ ] In `iac/terraform/0_projects/outputs.tf`, export the created project IDs, names, and other relevant details. This will serve as the input for the subsequent `1_apps` stage.

- [ ] **Phase 3: Placeholder for Application Deployment (`1_apps`)**
    - [ ] In `iac/terraform/1_apps/`, create a `README.md` file.
    - [ ] The `README.md` will explain that this stage is for application deployment and will consume the outputs from the `0_projects` stage. It will serve as a placeholder for future implementation.

- [ ] **Phase 4: Documentation**
    - [ ] Create a `README.md` in `iac/terraform/` explaining the new workflow: how to use the script and apply the Terraform configurations.
