# ☁️ SaaS Runtime Setup for Sandmold

This directory contains scripts and configurations to set up and deploy a sample VM using Google Cloud SaaS Runtime.

## Prerequisites

*   **Google Cloud CLI (gcloud)**: Authenticated and configured for your Google Cloud project.
*   **just**: A command runner (similar to `make`).

**Note**. Since APIs are still a bit clunky, we've experimented with both GLOBAL and REGIONAL endpoints (Unit Kinds, SaaS and so on) until we reach consensus that one approach is better than another.

## Setup


### 1. Configure Environment Variables

Copy `.env.dist` to `.env` and populate it with your project-specific details.

```bash
cp .env.dist .env
```

**Important:** The `.env` file should contain all the environment variables required by the scripts.

### 2. Initial Environment Setup

This script enables necessary Google Cloud APIs and grants required IAM permissions.

```bash
bin/00-setup-env.sh
```

## Workflow

The recommended way to deploy a complete SaaS environment is to use the `deploy-saas-end2end` command in the `justfile`. This will run all the necessary steps in the correct order.

```bash
just deploy-saas-end2end
```

<details>
<summary>Advanced: Manual Workflow</summary>

If you need more granular control, you can run the scripts individually. Follow these steps in order:

1.  **Create SaaS Offerings:**
    ```bash
    bin/01-create-saas.sh
    ```

2.  **Create Unit Kinds:**
    ```bash
    bin/02-create-unit-kind.sh
    ```

3.  **Build and Push Blueprint:**
    ```bash
    bin/03-build-and-push-blueprint.sh terraform-modules/terraform-vm
    ```

4.  **Create Release:**
    ```bash
    bin/04-create-release.sh
    ```

5.  **Create a Unit:**
    ```bash
    bin/05-create-unit.sh <unit-name>
    ```
    For example:
    ```bash
    bin/05-create-unit.sh my-first-vm
    ```

6.  **Provision the Unit:**
    ```bash
    bin/06-provision-unit.sh <unit-name>
    ```
    For example:
    ```bash
    bin/06-provision-unit.sh my-first-vm
    ```

</details>

## Ops

### Updating the Default Release for a Unit Kind

When you create a new release (e.g., `v1-0-1`), you need to update the corresponding Unit Kind to make that release the default for new unit provisioning.

1.  **Update your `.env` file:** Change the `RELEASE_NAME` variable to your new release name (e.g., `RELEASE_NAME="sample-vm-v1-0-1"`).

2.  **Run the update command:**

    ```bash
    source .env && \
    gcloud beta saas-runtime unit-kinds update ${UNIT_KIND_NAME} \
        --default-release=${RELEASE_NAME} \
        --location=${GOOGLE_CLOUD_REGION} \
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

## Cleanup

To destroy all the SaaS Runtime resources created by these scripts, you can run the following command. **Warning:** This is a destructive operation.

```bash
bin/dangerous-destroy-all-saas-entities.sh
```
