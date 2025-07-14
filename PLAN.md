### Plan: A Modular, DRY, and Scalable Terraform Setup (v2)

This revised plan incorporates feedback from `doc/POTENTIAL_GAPS.md` to ensure a more robust and user-friendly implementation.

- [ ] **Phase 1: Foundational Modules and Interfaces**
    - [ ] Create `doc/TF_INTERFACES.md` to formally document the Input/Output contract for all modules, including a Mermaid diagram.
    - [ ] Create the core reusable module: `iac/terraform/modules/project/`. This will be the single source of truth for creating/sourcing a GCP project, enabling APIs, and setting IAM.
    - [ ] Create the directory structure: `iac/terraform/1a_classroom_setup/`, `iac/terraform/1b_single_user_setup/`, and `iac/terraform/2_apps_deployment/`.

- [ ] **Phase 2: Scripts and Configuration**
    - [ ] Create a `project_config.yaml` in `etc/` to define the standard set of APIs and IAM roles for any project.
    - [ ] Create a Python script `bin/prepare_tf_vars.py` that parses the classroom YAML and `project_config.yaml` to generate the `terraform.tfvars.json` for the classroom setup.
    - [ ] Create a second Python script `bin/generate_report.py` responsible for creating the final `REPORT.md` from Terraform's output.

- [ ] **Phase 3: Classroom Configuration (`1a_classroom_setup` - CUJ001)**
    - [ ] This configuration will create the `google_folder`, grant `teachers` folder-level roles, and use a `for_each` loop to call the `modules/project` for each student.
    - [ ] Its `outputs.tf` will produce a `projects` map compatible with the `2_apps_deployment` stage.

- [ ] **Phase 4: Single User Configuration (`1b_single_user_setup` - CUJ002)**
    - [ ] This will be a lean wrapper around the `modules/project` module.
    - [ ] Its `README.md` will provide clear instructions for users, including how to use an **existing project** by setting `create_project = false`.
    - [ ] Its `outputs.tf` will produce a `projects` map structurally identical to the classroom output.

- [ ] **Phase 5: Application Deployment Placeholder (`2_apps_deployment`)**
    - [ ] This configuration will be designed to be agnostic of the preceding stage.
    - [ ] Its placeholder `README.md` will be updated to include a **sub-plan**, outlining the future strategy for parsing `blueprint.yaml` files and translating them into deployment actions (e.g., using a Helm or Kubernetes provider).

- [ ] **Phase 6: Orchestration and Documentation**
    - [ ] Create a master **wrapper script** (e.g., in `justfile` or `setup.sh`) that orchestrates the entire workflow:
        1.  Calls `prepare_tf_vars.py`.
        2.  Runs `terraform apply` and captures `stdout`/`stderr` to a log file for rich error analysis.
        3.  Calls `generate_report.py`, feeding it the log file contents.
    - [ ] Update the main `README.md` in `iac/terraform/` to explain the new modular architecture and the workflows.
    - [ ] The `doc/TF_INTERFACES.md` will serve as the detailed technical documentation for the module contracts.
    - [ ] The `generate_report.py` script will create the final `REPORT.md`.
