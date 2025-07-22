# Terraform Configuration for Sandmold

This directory contains the Terraform configurations for creating and managing Sandmold environments. The configuration is divided into several directories, each with a specific purpose.

## Directory Structure

-   **`1a_classroom_setup/`**: This directory contains the Terraform configuration for setting up the basic classroom structure. This includes creating the parent folder and the "schoolbench" projects for teachers and students. It utilizes the `modules/project` module to create the individual projects.

-   **`1b_single_user_setup/`**: This directory contains the Terraform configuration for setting up a single-user environment. This is a lighter version of the classroom setup, designed for individual users.

-   **`2_apps_deployment/`**: This directory contains the Terraform configuration for deploying applications to the "schoolbench" projects created in the `1a_classroom_setup` phase.

-   **`modules/`**: This directory contains reusable Terraform modules that are used by the other configurations.
    -   **`project/`**: A reusable module for creating and managing a single Google Cloud project. It handles project creation, API enablement, and IAM permissions.

-   **`sandmold/`**: This directory acts as a top-level composition layer that orchestrates the entire classroom creation and application deployment process. It uses the `1a_classroom_setup` and `2_apps_deployment` modules to create a complete Sandmold environment with a single `terraform apply` command. This is the primary entry point for creating a new classroom.

-   **`output/`**: This directory is used to store the output of the terraform commands.

## Usage

To create a new Sandmold environment, you should run `terraform apply` from the `sandmold` directory. This will create the classroom folder, the schoolbench projects, and deploy the specified applications.