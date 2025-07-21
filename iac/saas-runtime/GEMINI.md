I want to try to use SaaS runtime for sandmold project.

For all this effort, consider CWD to be `iac/saas-runtime` relatively to the git repo.

## Vision

I want to create 3 SaaS offerings.

## Zero SaaS - The "Hello World"

*   **Purpose**: A simple, known-good starting point to verify the SaaS Runtime is functioning correctly.
*   **Implementation**: Based on the existing `terraform-vm` code.
*   **Unit Kind**: `simple-vm`
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

## Docs

*   End to end tutorial: https://cloud.google.com/saas-runtime/docs/deploy-vm . Check here for order of actions to do:

### SaaS Runtime Entity Creation Order

1.  **Prerequisites**
    *   Enable required APIs: SaaS Runtime, Artifact Registry, Infrastructure Manager, Developer Connect, Cloud Build, Cloud Storage.
    *   Create a Service Account with "Owner" role.
    *   Grant permissions to the SaaS runner service account (`service-PROJECT-NUMBER@gcp-sa-saasservicemgmt.iam.gserviceaccount.com`).

2.  **SaaS Workflow**
    1.  **Create Artifact Registry Repository**: This will store your Terraform blueprints.
        ```bash
        gcloud artifacts repositories create REPO_NAME --repository-format=docker --location=REGION
        ```
    2.  **Create SaaS Offering**: This is the top-level resource for your service.
        ```bash
        gcloud beta saas-runtime offerings create OFFERING_NAME --display-name="My SaaS Offering" --publisher-id=PUBLISHER_ID
        ```
    3.  **Create Unit Kind**: This defines the type of resource you want to provision (e.g., a VM, a GKE cluster).
        ```bash
        gcloud beta saas-runtime unit-kinds create UNIT_KIND_NAME --offering=OFFERING_NAME --display-name="My Unit Kind" --blueprint-repo=AR_REPO_URL
        ```
    4.  **Create a Release**: This is a specific version of your Unit Kind, tied to a specific Terraform blueprint.
        ```bash
        gcloud beta saas-runtime releases create RELEASE_NAME --unit-kind=UNIT_KIND_NAME --offering=OFFERING_NAME --blueprint-version=BLUEPRINT_VERSION
        ```
    5.  **Provision a Unit**: This creates an actual instance of your service.
        ```bash
        gcloud beta saas-runtime units create UNIT_NAME --release=RELEASE_NAME --unit-kind=UNIT_KIND_NAME --offering=OFFERING_NAME --parameters=KEY=VALUE,...
        ```

*   Test project: `arche-275907`

## Permissions

Comands i needed tun run:

```bash
gcloud projects add-iam-policy-binding arche-275907 --member="user:admin@sredemo.dev" --role="roles/serviceusage.serviceUsageAdmin" --condition none

```
