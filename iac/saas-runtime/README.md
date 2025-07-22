# SaaS Runtime Setup for Sandmold

This directory contains scripts and configurations to set up and deploy a sample VM using Google Cloud SaaS Runtime. The goal is to demonstrate the end-to-end workflow of creating SaaS Offerings, Unit Kinds, Blueprints, Releases, and Units.

## Prerequisites

Before you begin, ensure you have the following installed and configured:

*   **Google Cloud CLI (gcloud)**: Authenticated and configured for your Google Cloud project.
*   **just**: A command runner (similar to `make`).

## Setup

### 1. Configure Environment Variables

Create a `.env` file in this directory and populate it with your project-specific details. You can use `.env.dist` as a template.

```bash
# .env

# -- GCP Project Details --
# The project ID where the SaaS Runtime and its resources will be deployed.
export GOOGLE_CLOUD_PROJECT="your-gcp-project-id"

# The primary region for your resources.
export GOOGLE_CLOUD_REGION="your-gcp-region" # e.g., europe-west1

# Your Google Cloud identity (email address).
export GOOGLE_IDENTITY="your-email@example.com"

# The name of the Artifact Registry repository to store blueprints.
export ARTIFACT_REGISTRY_NAME="sandmold-saas-registry"

# Your Google Cloud Project Number.
# You can get this by running: gcloud projects describe <your-gcp-project-id> --format="value(projectNumber)"
export PROJECT_NUMBER="your-gcp-project-number"

# The service account used by Cloud Build to build the blueprint.
# This is typically <PROJECT_NUMBER>@cloudbuild.gserviceaccount.com
export CLOUD_BUILD_SA="${PROJECT_NUMBER}@cloudbuild.gserviceaccount.com"

# -- SaaS Offering Base Name --
# A base name for your SaaS Offerings (global and regional will be derived from this).
export SAAS_OFFERING_NAME="sandmold-hello-world"

# -- Unit Kind Base Names --
# Base names for your Unit Kinds (global and regional will be derived from this).
export UNIT_KIND_NAME_GLOBAL="sandmold-sample-vm-global"
export UNIT_KIND_NAME_REGIONAL="sandmold-sample-vm-regional"

# -- Release Name --
# The name for your Release. Must be lowercase, alphanumeric, and can contain hyphens.
export RELEASE_NAME="v1-0-0"
```

### 2. Initial Environment Setup

This script enables necessary Google Cloud APIs and grants required IAM permissions to the SaaS Runtime service account.

```bash
bin/00-setup-env.sh
```

## SaaS Runtime Workflow

Follow these steps in order to deploy your sample VM.

### 1. Create SaaS Offerings

This script creates both a global and a regional SaaS Offering.

```bash
bin/01-create-saas.sh
```

### 2. Create Unit Kinds

This script creates both a global and a regional Unit Kind, associated with their respective SaaS Offerings.

```bash
bin/02-create-two-unit-kinds.sh
```

### 3. Build and Push Blueprint

This script takes a Terraform module directory, generates the necessary `Dockerfile.Blueprint` and `cloudbuild.yaml` files in a temporary `build/` directory, and then builds and pushes the blueprint to Artifact Registry.

```bash
bin/03-build-and-push-blueprint.sh terraform-modules/terraform-vm
```

### 4. Create Release

This script creates a Release, linking it to the global Unit Kind and the blueprint you just pushed. It also sets default input variables for the VM (like `instance_name` and `project_id`).

```bash
bin/04-create-release.sh
```

### 5. Create Units

You can create individual Units (VM instances) using the `just` commands. The VM name will be derived from the Unit name you provide.

*   **Create a Global Unit:**
    ```bash
    just create-global-unit my-first-global-vm
    ```
*   **Create a Second Global Unit:**
    ```bash
    just create-global-unit my-second-global-vm
    ```
*   **Create a Regional Unit:**
    ```bash
    just create-regional-unit my-first-regional-vm
    ```
*   **Create a Second Regional Unit:**
    ```bash
    just create-regional-unit my-second-regional-vm
    ```

### 6. Trigger Rollout (Provisioning)

Creating a Unit via the CLI only registers it. To trigger the actual VM provisioning (Terraform apply), you need to create a Rollout. This Rollout will target all Units associated with the global Unit Kind.

```bash
bin/06-create-rollout.sh
```

## Verification

You can check the status of all your SaaS Runtime resources using the `just check` command:

```bash
just check
```

This will list your SaaS Offerings, Unit Kinds, Blueprints, Units, and Releases. Note that Unit provisioning might take some time.

To verify the actual Compute Engine VMs, you can use the Google Cloud Console or the `gcloud compute instances list` command:

```bash
gcloud compute instances list --project="your-gcp-project-id"
```

## Cleanup (Optional)

To tear down all created resources, you would typically delete the Units first, then the Releases, then the Unit Kinds, and finally the SaaS Offerings. You would also need to delete the blueprint from Artifact Registry.

**Note:** Deleting resources in SaaS Runtime can be complex due to dependencies. It's often easier to delete the entire Google Cloud project if it's a test project.
