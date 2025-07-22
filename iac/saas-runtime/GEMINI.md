I want to try to use SaaS runtime for sandmold project.

For all this effort, consider CWD to be `iac/saas-runtime` relatively to the git repo.

I've documented how SaaS Runtime work in `ABOUT_SAAS_RUNTIME.md`. Ensure you read that at startup.

## Vision

I want to create 3 SaaS offerings.

## Rules of the game

* DRY variables and constants in `.env`
* do NOT write `.env` but ask user to do it as needed.
* Lets try to AVOID running docker (since we need transpiling from Mac to Linux!) unless strongly needed.

## Zero SaaS - The "Hello World"

*   **Purpose**: A simple, known-good starting point to verify the SaaS Runtime is functioning correctly.
*   **Implementation**: Based on the existing `terraform-vm` code.
*   **Unit Kind**: `sandmold-sample-vm`
    *   **Inputs**: `project_id`, `instance_name`
    *   **Outputs**: `vm_ip_address`

## First SaaS - Bank of Anthos (BoA) as a Service

*   **Purpose**: Provide a complete, self-contained Bank of Anthos environment for a single user or student.
*   **Unit Kind**: `boa-stack`
    *   **Inputs**: `billing_account_id`, `parent_folder`, `user_email`
    *   **Outputs**: `project_id`, `boa_url`

## Second SaaS - Hipster Shop as a Service

*   **Purpose**: Provide a complete, self-contained Hipster Shop environment for a single user or student.
*   **Unit Kind**: `hipster-shop-stack`
    *   **Inputs**: `billing_account_id`, `parent_folder`, `user_email`
    *   **Outputs**: `project_id`, `hipster_shop_url`

## Third SaaS - Classroom as a Service

*   **Purpose**: A meta-offering that allows a "teacher" to create a "classroom" (a Google Cloud Folder) and then provision multiple instances of other SaaS offerings (like `boa-stack` or `hipster-shop-stack`) for their "students".
*   **Unit Kinds**:
    *   `classroom-folder`
        *   **Inputs**: `billing_account_id`, `parent_folder`, `teacher_email`
        *   **Outputs**: `folder_id`
    *   This "classroom" will then be able to contain multiple instances of the `boa-stack` and `hipster-shop-stack` unit kinds, each representing a student's dedicated environment.

# Evolution

For v0, we will create the full stack for each SaaS offering. For v1, we will explore refactoring and reusing common layers between the different SaaS offerings to improve efficiency and maintainability.

## Plan of action

1. Try to reproduce the ENTIRE hellow world in  https://cloud.google.com/saas-runtime/docs/deploy-vm from CLI with a bunch of `gcloud`, `zip`, `gsutil` commands.
2. Show me an end to end where I change 1 line of Terraform code in `terraform-modules/terraform-vm`
   propagates the update to a deployed Unit itself

## Docs

*   End to end tutorial: https://cloud.google.com/saas-runtime/docs/deploy-vm . Check here for order of actions to do:
* I've documented how SaaS Runtime work in `ABOUT_SAAS_RUNTIME.md`. Ensure you read that at startup.
* Test project: `arche-275907`.
