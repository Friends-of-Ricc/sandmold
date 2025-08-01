## SaaS Runtime Entity Creation Order

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
        gcloud beta saas-runtime offerings create SAAS_OFFERING_NAME --location=global --locations=name=REGION_1 --locations=name=REGION_2
        ```
        Replace `SAAS_OFFERING_NAME` with a name for your SaaS offering, and `REGION_1`, `REGION_2` (and so on) with the regions where you want to host the deployments.
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

### Creating and Uploading a Blueprint

To create and upload a blueprint, which is a Terraform configuration packaged as an Open Container Initiative (OCI) image, you can use Cloud Build.

1.  **Create a `cloudbuild.yaml` file**: In the root of your Terraform repository, create a file named `cloudbuild.yaml` with the following configuration. This file defines the steps for building and pushing your blueprint image to Artifact Registry.

    ```yaml
    steps:
    - id: 'Create Dockerfile'
      name: 'bash'
      args: ['-c', 'echo -e "# syntax=docker/dockerfile:1-labs\nFROM scratch\nCOPY --exclude=Dockerfile.Blueprint --exclude=.git --exclude=.gitignore . /" > Dockerfile.Blueprint']
    - id: 'Create docker-container driver'
      name: 'docker'
      args: ['buildx', 'create', '--name', 'container', '--driver=docker-container']
    - id: 'Build and Push docker image'
      name: 'docker'
      args: ['buildx', 'build', '-t', '${_IMAGE_NAME}', '--builder=container', '--push', '--annotation', 'com.easysaas.engine.type=${_ENGINE_TYPE}','--annotation', 'com.easysaas.engine.version=${_ENGINE_VERSION}', '--provenance=false','-f', 'Dockerfile.Blueprint', '.']
    serviceAccount: '${_SERVICE_ACCOUNT}'
    substitutions:
      _SERVICE_ACCOUNT: 'projects/PROJECT_ID/serviceAccounts/CLOUD_BUILD_SERVICE_ACCOUNT'
      _IMAGE_NAME: 'us-docker.pkg.dev/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME:latest'
      _ENGINE_TYPE: 'inframanager'
      _ENGINE_VERSION: 'TERRAFORM_VERSION'
    options:
      logging: CLOUD_LOGGING_ONLY
    ```
    **Replace the following placeholders** in the `cloudbuild.yaml`:
    *   `PROJECT_ID`: Your Google Cloud project ID.
    *   `CLOUD_BUILD_SERVICE_ACCOUNT`: The full name of your Cloud Build service account.
    *   `REPOSITORY_NAME`: The name of your Artifact Registry repository.
    *   `IMAGE_NAME`: A name for your blueprint image.
    *   `TERRAFORM_VERSION`: The supported version of Terraform to use.

2.  **Submit the Cloud Build job**: From the directory containing your `cloudbuild.yaml` file, run the following `gcloud builds submit` command to start the build process:

    ```bash
    gcloud builds submit --config=cloudbuild.yaml --substitutions=_IMAGE_NAME='us-docker.pkg.dev/PROJECT_ID/REPOSITORY_NAME/IMAGE_NAME:TAG'
    ```
    **Replace the following placeholders** in the command:
    *   `PROJECT_ID`: Your Google Cloud project ID.
    *   `REPOSITORY_NAME`: The name of your Artifact Registry repository.
    *   `IMAGE_NAME`: A name for your blueprint image.
    *   `TAG`: A tag for your image version (e.g., `latest` or `v1.0.0`). Choosing a descriptive tag helps manage blueprint versions effectively.

This process will build your OCI image and push it to the specified Artifact Registry repository.

## Managing Unit Kinds

The documentation for modeling and packaging units of deployment primarily describes how to create and manage Unit Kinds using the Google Cloud Console UI, not directly via `gcloud` commands.

Here's a summary of how Unit Kinds are modeled and packaged:
*   **Unit Kind Definition**: A unit of deployment in SaaS Runtime is called a unit kind. Each unit kind represents a component of a SaaS offering that you want to manage independently.
*   **Blueprint**: Unit kinds are defined by a blueprint, which is a Terraform configuration packaged as an OCI image.
*   **Creation Methods**: You can create a unit kind using a Terraform configuration provided in:
    *   A zip archive.
    *   A Git repository.
    *   An existing OCI image.
*   **Dependencies and Variable Mapping**: When creating unit kinds, you can define dependencies between them and map input and output variables to facilitate communication between different unit kinds within a SaaS offering.

The document does not provide specific `gcloud` commands for these operations. It guides users through the console interface for creating and configuring unit kinds, including steps for uploading zip archives, linking Git repositories, or selecting existing OCI images from Artifact Registry.

## Updating SaaS Offerings (Rollouts)

To update a SaaS offering, you need to follow these steps: create a release, create a rollout kind, and then create a rollout.

**Operational Information:**
*   SaaS Runtime uses **rollouts** to update multiple provisioned units.
*   Rollouts target units based on their `UnitKind` and can use filters to target specific subsets of units.
*   A **rollback** can be performed by upgrading units to a previous release.
*   The **error budget** feature (`ErrorBudget` in `RolloutKind`) can automatically pause a rollout if the number or percentage of unit update failures exceeds a configured threshold.

**`gcloud` Commands:**

1.  **Create a Release:**
    A release represents a specific version of your SaaS application, defined by a blueprint package and its configurations.
    ```bash
    gcloud beta saas-runtime releases create RELEASE_NAME \
        --blueprint-package=BLUEPRINT_PACKAGE_URI \
        --unit-kind=UNIT_KIND \
        [--location=LOCATION] \
        [--labels=[KEY=VALUE,...]] \
        [--upgradeable-from-releases=[RELEASE_NAME,...]] \
        [--input-variable-defaults=[variable=VARIABLE,value=VALUE,type=TYPE,...]]
    ```
    *   `RELEASE_NAME`: The ID of the release.
    *   `BLUEPRINT_PACKAGE_URI`: The URI of the blueprint package (OCI image).
    *   `UNIT_KIND`: The ID or fully qualified identifier for the unit kind.
    *   `LOCATION`: (Optional) The location where you want to create the release.
    *   `LABELS`: (Optional) Labels to apply to the release.
    *   `UPGRADEABLE_FROM_RELEASES`: (Optional) A comma-separated list of release names that specifies which existing releases can be updated with the new release.
    *   `INPUT_VARIABLE_DEFAULTS`: (Optional) Default values for input variables.

2.  **Create a Rollout Kind:**
    A rollout kind serves as a template for how your release is deployed to your units, defining the rollout strategy and potentially an error budget.
    ```bash
    gcloud beta saas-runtime rollout-kinds create ROLLOUT_KIND_NAME \
        --unit-kind=UNIT_KIND \
        --location=LOCATION \
        --rollout_strategy=ROLLOUT_STRATEGY \
        [--error_budget=ERROR_BUDGET] \
        [--unit_filter=UNIT_FILTER] \
        [--update_unit_kind_default=UPDATE_UNIT_KIND_DEFAULT]
    ```
    *   `ROLLOUT_KIND_NAME`: The name of the rollout kind.
    *   `UNIT_KIND`: Defines which units you want to apply releases to.
    *   `LOCATION`: The location where you want to create your rollout kind.
    *   `ROLLOUT_STRATEGY`: Defines the rollout strategy (e.g., `Google.Cloud.Simple.AllAtOnce`, `Google.Cloud.Simple.OneLocationAtATime`).
    *   `ERROR_BUDGET`: (Optional) Configuration for error budget.
    *   `UNIT_FILTER`: (Optional) CEL formatted filter string used against units.
    *   `UPDATE_UNIT_KIND_DEFAULT`: (Optional) Configuration for updating the unit kind.

3.  **Create a Rollout:**
    A rollout specifies the release you want to update your units with, using a defined rollout kind.
    ```bash
    gcloud beta saas-runtime rollouts create ROLLOUT_NAME \
        --rollout-kind=ROLLOUT_KIND_NAME \
        --release=RELEASE_NAME \
        --location=LOCATION
    ```
    *   `ROLLOUT_NAME`: The name of the rollout.
    *   `ROLLOUT_KIND_NAME`: Defines which rollout kind to use.
    *   `RELEASE_NAME`: Defines the release binary to deploy.
    *   `LOCATION`: The location where you want to create your rollout.

## Glossary

*   **SaaS offering**: A SaaS offering represents a specific software as a service (SaaS) product offering, including details, configurations, and deployment regions that may be shared across multiple instances or deployments of that product within a company's larger SaaS portfolio.
*   **Unit**: A unit is an instantiation of a unit kind. For example, if you have a unit kind for the infrastructure of your SaaS application, then the related unit is the infrastructure wherein the application runs.
*   **Unit kind**: A unit kind defines a type of managed component within your service (for example, a Kubernetes cluster, or an application instance). All units of a given unit kind are typically updated together (via a rollout). Unit kinds enable you to define separate rollout content and cadences for distinct groupings within your SaaS offering.
*   **Release**: A release represents a specific, deployable snapshot of a unit kind. Releases contain the artifacts and configurations to create or update a unit. Releases include a pointer to an artifact encapsulating the actual deployment details (including the Terraform configuration). When you want to update a unit, you target a specific release in a rollout.
*   **Rollout**: A rollout is the process of updating units with a new release. A rollout process follows the rules defined in the rollout kind.
*   **Rollout kind**: A rollout kind functions as a description of how to deploy new releases to units. For example, you can set the rollout to progress by specific increments in the regions where the units are available.
*   **Tenant**: A tenant represents a dedicated instance of the SaaS offering. It acts as a container for all the units (containing applications, databases, and infrastructure components) that you provision and manage.
*   **Feature flag**: Feature flags toggle the state or other binary behaviors of a feature. Feature flags allow you to change feature availability or feature behavior without redeploying or restarting the application.

## Project Vision and SaaS Offerings

This project aims to create 3 SaaS offerings within the SaaS Runtime framework:

*   **Zero SaaS - The "Hello World"**:
    *   **Purpose**: A simple, known-good starting point to verify the SaaS Runtime is functioning correctly.
    *   **Implementation**: Based on the existing `terraform-vm` code.
    *   **Unit Kind**: `simple-vm`
        *   **Inputs**: `project_id`, `instance_name`
        *   **Outputs**: `vm_ip_address`

*   **First SaaS - Bank of Anthos (BoA) as a Service**:
    *   **Purpose**: Provide a complete, self-contained Bank of Anthos environment for a single user or student.
    *   **Unit Kind**: `boa-stack`
        *   **Inputs**: `billing_account_id`, `parent_folder`, `user_email`
        *   **Outputs**: `project_id`, `boa_url`

*   **Second SaaS - Hipster Shop as a Service**:
    *   **Purpose**: Provide a complete, self-contained Hipster Shop environment for a single user or student.
    *   **Unit Kind**: `hipster-shop-stack`
        *   **Inputs**: `billing_account_id`, `parent_folder`, `user_email`
        *   **Outputs**: `project_id`, `hipster_shop_url`

*   **Third SaaS - Classroom as a Service**:
    *   **Purpose**: A meta-offering that allows a "teacher" to create a "classroom" (a Google Cloud Folder) and then provision multiple instances of other SaaS offerings (like `boa-stack` or `hipster-shop-stack`) for their "students".
    *   **Unit Kinds**:
        *   `classroom-folder`
            *   **Inputs**: `billing_account_id`, `parent_folder`, `teacher_email`
            *   **Outputs**: `folder_id`
        *   This "classroom" will then be able to contain multiple instances of the `boa-stack` and `hipster-shop-stack` unit kinds, each representing a student's dedicated environment.

## SaaS Runtime Architecture and Relationships

The SaaS Runtime is built around several core components that interact to provision and manage SaaS offerings. Understanding these relationships is crucial for effective use of the platform.

**Key Entities and Their Relationships:**

*   **SaaS Offering**: The overarching service product. It *defines* and contains various Unit Kinds.
*   **Unit Kind (UK)**: A template or type of managed component (e.g., a VM, a database, an application stack). A SaaS Offering *has* multiple Unit Kinds.
*   **Release**: A specific, versioned snapshot of a Unit Kind's configuration (its Blueprint). A Unit Kind *has* multiple Releases.
*   **Blueprint**: The Infrastructure-as-Code (IaC) package (typically a Terraform module packaged as an OCI image) that defines how to create a resource. A Release *is created from* a Blueprint.
*   **Unit**: An actual, running instance of a Unit Kind. A Unit Kind *instantiates* Units, and a Unit *is provisioned from* a specific Release.
*   **Terraform Module**: The raw Terraform code that a Blueprint *is built from*.

**Dependencies and Caveats:**

The relationships imply a clear dependency flow:
*   A **Unit** depends on a **Unit Kind** (for its type) and a **Release** (for its versioned configuration).
*   A **Release** depends on a **Unit Kind** (it's a release *of* that kind) and a **Blueprint** (which contains the configuration).
*   A **Blueprint** depends on a **Terraform Module** (the source code).
*   A **Unit Kind** depends on a **SaaS Offering** (its parent container).

**⚠️ Circular Dependency between Unit Kind and Release:**

A common point of confusion arises from a potential circular dependency:
*   A **Unit Kind** can have a `default_release`.
*   A **Release** must belong to a **Unit Kind**.

This means you cannot set a `default_release` on a Unit Kind until the Release exists, and you cannot create a Release without a Unit Kind. The solution is to first create the Unit Kind *without* a default release, then create the Release, and finally, update the Unit Kind to set the newly created release as the default.

For a visual representation of these relationships, please refer to `ER_DIAGRAM.md`.

## Known Issues and Workarounds

This section outlines some common friction points encountered when working with SaaS Runtime and their current resolutions or workarounds.

### Manifest Digest Mismatch Error with Artifact Registry Blueprints

**Problem:** Persistent `INVALID_ARGUMENT: invalid argument unable to read annotations from OCI image, error: manifest digest: "sha256:..." does not match requested digest: "sha256:..."` errors when attempting to create SaaS Runtime Releases from blueprints stored in Artifact Registry. This suggests issues with how the SaaS Runtime service resolves or caches blueprint image references.

**Workaround:** Transition to using GCS-based ZIP files for Terraform blueprints. This involves:
*   Modifying the blueprint build process to create and upload ZIP archives to a dedicated GCS bucket.
*   Updating release creation commands to reference these GCS paths instead of Artifact Registry image URIs.

### `gsutil` Reauthentication Issue

**Problem:** `gsutil` commands failing with `google_reauth.errors.ReauthUnattendedError: Reauthentication challenge could not be answered because you are not in an interactive session.` during script execution, even after successful interactive `gcloud auth login` and `gcloud auth application-default login`. This indicates `gsutil` is unable to use existing application default credentials in a non-interactive script environment, or credentials are expiring too quickly.

**Workaround:** (Implicit from context, but not explicitly stated as a workaround in the log) Ensure that the environment where `gsutil` is run has valid and non-expiring credentials, or consider using service account keys directly for `gsutil` operations in automated scripts if application default credentials prove unreliable.

## Operational Tasks

### Updating the Default Release for a Unit Kind

When you create a new release (e.g., `v1-0-1`), you need to update the corresponding Unit Kind to make that release the default for new unit provisioning.

1.  **Update your `.env` file:** Change the `RELEASE_NAME` variable to your new release name (e.g., `RELEASE_NAME="sample-vm-v1-0-1"`).

2.  **Run the update command:**

    ```bash
    source .env && \
    gcloud beta saas-runtime unit-kinds update ${UNIT_KIND_NAME_BASE}-global \
        --default-release=${RELEASE_NAME} \
        --location=global \
        --project=${GOOGLE_CLOUD_PROJECT}
    ```

### Verification

Check the status of all your SaaS Runtime resources:

```bash
just check
```

### Debugging Utilities

#### Get Error Logs

This script retrieves error logs from Google Cloud Logging for a specified number of hours.

```bash
bin/get-error-logs.sh [HOURS]
```

*   `HOURS`: Optional. The number of hours to look back for logs. Defaults to 24.

**Example:**

To get error logs from the last 12 hours:

```bash
bin/get-error-logs.sh 12
```