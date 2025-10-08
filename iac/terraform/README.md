# Terraform Configuration for Sandmold

This directory contains all Terraform configurations for the Sandmold project.

## Directory Structure

-   **`sandmold/`**: This is the primary entry point for creating Sandmold environments. It contains the top-level Terraform configurations that compose the modules for classroom setup, single-user setup, and application deployment. You should generally run `terraform` commands from within this directory, although using the `just` commands in the root is the recommended approach.

-   **`modules/`**: This directory contains generic, reusable Terraform modules that are used by the configurations in the `sandmold/` directory. For example, it contains a module for creating a standard Google Cloud project.
