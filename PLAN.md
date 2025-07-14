### Plan: A Modular, DRY, and Scalable Terraform Setup

This plan outlines a robust, professional, and maintainable Terraform architecture using modules to support all requirements, including CUJ001 (Classroom) and CUJ002 (Single User).

- [ ] **Phase 1: Foundational Modules and Interfaces**
    - [ ] Create a new file `doc/TF_INTERFACES.md` to formally document the Input/Output contract for all modules and configurations. It should also have a Mermaid graph to show this visually.
    - [ ] Create the core reusable module: `iac/terraform/modules/project/`. This module will be responsible for creating/sourcing a single GCP project, enabling APIs, and setting IAM permissions. It will be the single source of truth for project configuration.
    - [ ] Create the directory structure for the different configurations: `iac/terraform/1a_classroom_setup/` (for CUJ001), `iac/terraform/1b_single_user_setup/` (for CUJ002), and `iac/terraform/2_apps_deployment/`.

- [ ] **Phase 2: Configuration Processing**
    - [ ] Create a `project_config.yaml` in `etc/` to define the standard set of APIs and IAM roles for any project.
    - [ ] Create a Python script (`bin/generate_tf_vars.py`) that parses the classroom YAML (e.g., `etc/class_2teachers_6students.yaml`) and `etc/project_config.yaml`.
        - [ ] The script will generate the `terraform.tfvars.json` file needed by the `1a_classroom_setup` configuration.
        - [ ] The script will also be responsible for generating a final `REPORT.md` after `terraform apply` is run.

- [ ] **Phase 3: Classroom Configuration (`1a_classroom_setup` - CUJ001)**
    - [ ] This configuration will be responsible for classroom-specific logic.
    - [ ] In `main.tf`, it will:
        - [ ] Create the `google_folder`.
        - [ ] Grant folder-level IAM roles to `teachers`.
        - [ ] Use a `for_each` loop to call the `modules/project` for each student, passing the appropriate variables.
    - [ ] In `outputs.tf`, it will output a `projects` map that is compatible with the `2_apps_deployment` stage.

- [ ] **Phase 4: Single User Configuration (`1b_single_user_setup` - CUJ002)**
    - [ ] This will be a very lean configuration that provides a simple experience for the single user.
    - [ ] It will primarily be a thin wrapper that calls the `modules/project` once.
    - [ ] It will feature a simple `variables.tf` and a clear `README.md` guiding the user on how to create their `terraform.tfvars` file.
    - [ ] Its `outputs.tf` will produce a `projects` map that is structurally identical to the classroom output, ensuring pluggability with the `2_apps_deployment` stage.

- [ ] **Phase 5: Application Deployment (`2_apps_deployment`)**
    - [ ] This configuration will be designed to be completely agnostic of the previous stage.
    - [ ] It will take the `projects` map as input and will be responsible for deploying the specified applications.
    - [ ] A `README.md` will serve as a placeholder for the actual deployment logic.

- [ ] **Phase 6: Documentation**
    - [ ] Update the main `README.md` in `iac/terraform/` to explain the new modular architecture and the workflows for both CUJ001 and CUJ002.
    - [ ] The `doc/TF_INTERFACES.md` will serve as the detailed technical documentation for the module contracts.
    - [ ] The Python script will generate the final `REPORT.md`.
