# Potential Gaps and Considerations

This document outlines potential gaps and considerations identified during the review of the project's Terraform implementation plan.

While the overall plan is very strong, addressing these points will ensure a more robust and user-friendly final product.

### 1. CUJ002 "Use Existing Project" Workflow

*   **Observation:** `REQUIREMENTS.md` states that for CUJ002 (single user mode), a user should be able to use an *existing* project. The `modules/project` interface defined in `doc/TF_INTERFACES.md` cleverly supports this with the `create_project: bool` variable.
*   **Gap:** The current plan for the `1b_single_user_setup` configuration does not explicitly mention how a user would signal this choice.
*   **Suggestion:** The `README.md` for `1b_single_user_setup` should be updated to clearly instruct users on how to configure their `terraform.tfvars` file to select an existing project. This would likely involve setting `create_project = false` and providing the specific `project_id`.

### 2. Python Script's Dual Role

*   **Observation:** `PLAN.md` specifies that the Python script (`bin/generate_tf_vars.py`) is responsible for two distinct tasks: generating `terraform.tfvars.json` (which happens *before* `terraform apply`) and creating a final `REPORT.md` (which happens *after* `terraform apply`).
*   **Gap:** This dual responsibility implies that the script needs to be run twice or must be designed with two separate modes of operation. This could complicate the script's logic and the overall workflow.
*   **Suggestion:** To improve clarity and maintainability, consider splitting this functionality into two separate, purpose-built scripts (e.g., `bin/prepare_tf_vars.py` and `bin/generate_report.py`). Alternatively, if a single script is preferred, the `justfile` or primary `README.md` should explicitly document that the script is called at different stages with different arguments or environment variables.

### 3. Application Deployment Logic (`Phase 5`)

*   **Observation:** The plan correctly defers the complex application deployment logic, defining a clear interface (the `projects` map) for the `2_apps_deployment` stage to consume.
*   **Gap:** This is the most significant piece of "forgotten" or deferred work. The current plan only involves creating a placeholder `README.md`, but the actual logic for "installing an app" will be non-trivial.
*   **Suggestion:** This is an acceptable strategy for a phased implementation. However, a sub-plan should be developed for how `2_apps_deployment` will eventually function. This future plan should detail how the configuration will parse the `blueprint.yaml` files (located in the `applications/` directory) and translate them into the necessary Terraform resources, Helm releases, or `gcloud` commands required to deploy the applications.

### 4. Error Handling and Final Report

*   **Observation:** `REQUIREMENTS.md` requires that the final report includes detailed, user-friendly error messages (e.g., "project boa03 couldnt be created since student06@gmail.com doesnt exist").
*   **Gap:** The plan does not specify the mechanism for capturing this detailed error information from the Terraform run. A standard `terraform apply` command typically returns a generic error code on failure, which is insufficient for a rich report.
*   **Suggestion:** A robust error-capturing mechanism is needed. This could be implemented by creating a wrapper script (e.g., in bash or Python) that executes the `terraform apply` command, captures its `stdout` and `stderr` streams, and parses this output to extract meaningful error messages. This parsed information can then be passed to the reporting script to be included in the final `REPORT.md`.
