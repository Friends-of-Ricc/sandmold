# SaaS Runtime Setup for Sandmold

This directory contains scripts and configurations to set up and deploy a sample VM using Google Cloud SaaS Runtime.

## Prerequisites

*   **Google Cloud CLI (gcloud)**: Authenticated and configured for your Google Cloud project.
*   **just**: A command runner (similar to `make`).
*   **direnv**: For managing environment variables.

## Setup

### 1. Configure Environment Variables

Copy `.env.dist` to `.envrc` and populate it with your project-specific details. Then, allow `direnv` to load it.

```bash
cp .env.dist .envrc
direnv allow
```

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

6.  **Trigger Rollout (Provisioning):**
    ```bash
    bin/06-create-rollout.sh
    ```

## Verification

Check the status of all your SaaS Runtime resources:

```bash
just check
```

## Cleanup (Optional)

Refer to Google Cloud documentation for detailed cleanup procedures. For test projects, deleting the entire project is often the simplest approach.