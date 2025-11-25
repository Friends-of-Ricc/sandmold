# Plan: Implement Application-Centric Infrastructure for Online Boutique (Issue #38)

This plan outlines the correct, architecturally sound approach to integrate the "Online Boutique" application into the classroom deployment process. The core principle is that application-specific infrastructure (like a GKE cluster) is defined within the application's own directory, and the central Terraform configuration acts as a generic orchestrator.

## Goal

A user adds `online-boutique` to a classroom YAML. The `just classroom-deploy-apps` command will:
1.  Trigger a generic Terraform module (`2_apps_deployment`) that calls the specific Terraform code within `applications/online-boutique/` to create a GKE cluster.
2.  Execute the application's own `start.sh` script, which will use `kubectl` to deploy the software to that new cluster.

---

## 1. Application-Specific Infrastructure (`applications/online-boutique/`)

This is where the application's own infrastructure will be defined.

-   [ ] **Create Terraform module directory**: Create a new directory `applications/online-boutique/terraform/`.
-   [ ] **Define GKE Cluster**: Inside this new directory, create `main.tf`, `variables.tf`, and `outputs.tf`.
    -   `main.tf` will contain the `google_container_cluster` resource for an Autopilot GKE cluster and enable the `container.googleapis.com` API.
    -   `variables.tf` will define the necessary inputs, such as `project_id`, `cluster_name`, and `location`.
    -   `outputs.tf` will output the created cluster's details.

## 2. Orchestration Layer (`iac/terraform/sandmold/2_apps_deployment/`)

This Terraform module will be the generic "glue" that calls the application-specific modules.

-   [ ] **Modify `iac/terraform/sandmold/2_apps_deployment/main.tf`**:
    -   This file will be the orchestrator. It will receive the `app_deployments` variable from the `justfile`.
    -   It will contain a `module "online_boutique" {}` block.
    -   The `source` for this module will be `../../../../applications/online-boutique/terraform`.
    -   It will use a `for_each` meta-argument to iterate over the `app_deployments` variable, creating an instance of the module only for projects that have `"online-boutique"` in their app list.
    -   It will pass the `project_id` from the loop into the module.
-   [ ] **Modify `iac/terraform/sandmold/2_apps_deployment/outputs.tf`**:
    -   This will be updated to aggregate and pass through the outputs from the application-specific modules it calls.

## 3. Deployment Script (`applications/online-boutique/`)

This is where the application's software deployment logic will live.

-   [ ] **Update `applications/online-boutique/start.sh`**:
    -   This script will be executed by the generic `bin/execute_app_deployment.py` script.
    -   It will receive the GKE cluster details (name, location, project ID) as environment variables from the Terraform output.
    -   It will contain the `gcloud container clusters get-credentials` command to configure `kubectl`.
    -   It will clone the `microservices-demo` repo into `vendor/` if it's not already there.
    -   It will run `kubectl apply -f vendor/microservices-demo/release/kubernetes-manifests.yaml`.
    -   It will contain the logic to wait for and print the `frontend-external` service's IP address.

## 4. Configuration & Verification

-   [ ] **Verify `bin/prepare_app_deployment.py` and `bin/execute_app_deployment.py`**: Ensure these "glue" scripts correctly pass variables from the YAML and Terraform outputs into the `start.sh` script's environment.
-   [ ] **Update `etc/samples/classroom/with_apps.yaml`**: Ensure `online-boutique` is present for testing.
-   [ ] **Run the full flow**: Execute `just classroom-up` followed by `just classroom-deploy-apps` and verify the application is deployed and accessible.
