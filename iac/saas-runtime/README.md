# SaaS Runtime Setup for Sandmold

This directory contains scripts and configurations to set up and deploy a sample VM using Google Cloud SaaS Runtime.

## Prerequisites

*   **Google Cloud CLI (gcloud)**: Authenticated and configured for your Google Cloud project.
*   **just**: A command runner (similar to `make`).

**Note**. Since APIs are still a bit clunky, we've experimented with both GLOBAL and REGIONAL endpoints (Unit Kinds, SaaS and so on) until we reach consensus that one approach is better than another.

## Setup


### 1. Configure Environment Variables

Copy `.env.dist` to `.envrc` and populate it with your project-specific details. Then, allow `direnv` to load it.

```bash
cp .env.dist .envrc
direnv allow
```

**Important:** The `.envrc` file should contain all the environment variables required by the scripts, including `GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_REGION`, `GOOGLE_IDENTITY`, `ARTIFACT_REGISTRY_NAME`, `PROJECT_NUMBER`, `CLOUD_BUILD_SA`, `SAAS_OFFERING_NAME`, `UNIT_KIND_NAME_GLOBAL`, `UNIT_KIND_NAME_REGIONAL`, and `RELEASE_NAME`.

### 2. Initial Environment Setup

This script enables necessary Google Cloud APIs and grants required IAM permissions.

```bash
bin/00-setup-env.sh
```

## Workflow

Follow these steps in order:

1.  **Create SaaS Offerings:**
    ```bash
    bin/01-create-saas.sh
    ```

2.  **Create Unit Kinds:**
    ```bash
    bin/02-create-two-unit-kinds.sh
    ```

3.  **Build and Push Blueprint:**
    ```bash
    bin/03-build-and-push-blueprint.sh terraform-modules/terraform-vm
    ```

4.  **Create Release:**
    ```bash
    bin/04-create-release.sh
    ```

5.  **Create Units:**
    *   Global Unit:
        ```bash
        just create-global-unit my-first-global-vm
        ```
    *   Regional Unit:
        ```bash
        just create-regional-unit my-first-regional-vm
        ```

6. Provision unit

    ```bash
    bin/06-provision-unit.sh <unit-name>
    ```

    For example:

    ```bash
    bin/06-provision-unit.sh my-first-global-vm
    ```

7.  **Trigger Rollout (Provisioning):**

7.  **Trigger Rollout (Provisioning):**
    ```bash
    bin/06-create-rollout.sh
    ```

## Ops

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

## Verification

Check the status of all your SaaS Runtime resources:

```bash
just check
```

## Debugging Utilities

### Get Error Logs

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

## Cleanup (Optional)

Refer to Google Cloud documentation for detailed cleanup procedures. For test projects, deleting the entire project is often the simplest approach.

```
