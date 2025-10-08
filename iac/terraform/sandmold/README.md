# Sandmold Terraform Configuration

This directory is the primary entry point for all Terraform configurations used to create and manage Sandmold environments.

## Directory Structure

The Terraform code is organized into modules representing the different logical components of a Sandmold classroom:

-   **`1a_classroom_setup/`**: Contains the core Terraform logic for setting up the basic classroom structure. This includes creating the parent folder and the "schoolbench" projects for both teachers and students.

-   **`1b_single_user_setup/`**: Contains the Terraform configuration for a lighter, single-project setup designed for individual users rather than a full classroom.

-   **`2_apps_deployment/`**: Contains the Terraform logic for deploying applications (the "curriculum") onto the projects created in the `1a_classroom_setup` phase.

-   **`modules/`**: Contains reusable Terraform modules that are leveraged by the other configurations.
    -   **`project/`**: A generic module for creating and configuring a single Google Cloud project, including API enablement and IAM permissions. This module is a critical component and is used by both the `1a_classroom_setup` and `1b_single_user_setup` configurations.

## Usage

While you can run `terraform` commands directly from these directories, the intended workflow is to use the scripts and `just` commands provided in the root of the repository. These wrappers ensure that the correct workspaces are selected and that the necessary variables are passed to Terraform.

Refer to the main `README.md` and the `doc/USER_MANUAL.md` for instructions on how to deploy and manage classrooms.
