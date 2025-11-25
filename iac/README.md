# Infrastructure as Code (IaC)

This directory contains all the Infrastructure as Code configurations and scripts for the Sandmold project. It is divided into two main subdirectories: `saas-runtime/` and `terraform/`.

## `saas-runtime/`

This subdirectory is dedicated to setting up and deploying sample Virtual Machines using Google Cloud's SaaS Runtime capabilities. It includes:

*   **Scripts:** Bash scripts for managing the lifecycle of SaaS offerings, unit kinds, releases, and units.
*   **Terraform Modules:** Specialized Terraform modules designed for SaaS Runtime deployments, such as `terraform-vm` (for VM provisioning) and `terraform-classroom-folder` (for classroom folder creation).
*   **Documentation:** Detailed `README.md` explaining the prerequisites, setup, workflow (including an end-to-end deployment target), operational procedures, verification steps, debugging utilities, and cleanup instructions.

For a deeper dive into this section, refer to the [SaaS Runtime README](saas-runtime/README.md).

## `terraform/`

This subdirectory holds the core Terraform configurations for provisioning the foundational Google Cloud infrastructure for Sandmold environments. It is structured as follows:

*   **`sandmold/`**: The primary entry point for creating Sandmold environments. It contains top-level Terraform configurations that orchestrate classroom setup, single-user setup, and application deployment.
*   **`modules/`**: Contains generic, reusable Terraform modules used by the `sandmold/` configurations (e.g., a module for creating standard Google Cloud projects).

For more detailed information, please refer to the [Terraform Configuration README](terraform/README.md).
