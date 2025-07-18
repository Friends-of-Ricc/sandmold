# Updated Plan for CUJ02: Cost-Effective Single User Setup

This plan outlines the steps to create a new, cost-effective single-user setup as described in issue #22, with a focus on supporting org-less projects.

## 1. Enhance the Terraform Module for Org-less Projects

The existing `iac/terraform/1b_single_user_setup` module will be modified to support the creation of org-less projects.

*   **`variables.tf`:**
    *   The `parent` variable will be removed.
    *   The `project_id` variable will be used for both creating a new project (as a prefix) and for specifying an existing project.
*   **`main.tf`:**
    *   The `parent` argument will be removed from the `module "project"` call. The underlying project module should handle this gracefully, creating an org-less project when no parent is specified.

## 2. Update the Sample YAML Configuration

The `etc/samples/single_user/light.yaml` file will be updated to reflect the new org-less approach.

*   The `parent_folder_id` field will be removed.
*   The `project_id_prefix` will be renamed to `project_id` for consistency with the Terraform variables. An optional `existing_project_id` will be added to allow users to bring their own project.

## 3. Update the `prepare_user_tf_vars.py` Script

The `bin/prepare_user_tf_vars.py` script will be updated to:

*   **Handle both new and existing projects.** It will check for the presence of `existing_project_id` in the YAML. If it exists, it will set `create_project = false` in the `tfvars` file. Otherwise, it will set `create_project = true`.
*   **Remove the `parent` variable** from the generated `tfvars` file.

## 4. Update the `just` Command and `user-up.sh` Script

The `just user-up` command and the `bin/user-up.sh` script will remain largely the same, but will now orchestrate the new org-less setup.

## 5. Update Documentation

The `README.md` file will be updated to include instructions on how to use the new org-less single-user setup, with examples for both creating a new project and using an existing one.