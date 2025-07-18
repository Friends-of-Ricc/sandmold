# Plan for CUJ02: Cost-Effective Single User Setup

This plan outlines the steps to create a new, cost-effective single-user setup as described in issue #22.

## 1. Use Existing Terraform Module

Instead of creating a new Terraform module, we will use the existing `iac/terraform/1b_single_user_setup` module. This module will be enhanced to support the new "light" configuration.

## 2. Create a New Sample YAML Configuration

A new sample YAML file, `etc/samples/single_user/light.yaml`, will be created. This file will serve as the configuration for the new single-user setup. It will be a simplified version of the existing `class_with_apps.yaml` file, with only the necessary fields for a single user.

## 3. Create a New `just` Command

A new command, `just user-up [yaml_file]`, will be added to the `justfile`. This command will:

*   **Accept an optional YAML file as input.** If no file is provided, it will default to `etc/samples/single_user/light.yaml`.
*   **Call a new `bin/user-up.sh` script.**

## 4. Create a New `user-up.sh` Script

A new Bash script, `bin/user-up.sh`, will be created to orchestrate the single-user setup. This script will be similar to the existing `classroom-up.sh` script and will:

*   **Create a Terraform workspace** based on the name in the YAML file.
*   **Parse the input YAML file.**
*   **Generate a `terraform.tfvars.json` file.**
*   **Run `terraform apply` in the `iac/terraform/1b_single_user_setup` directory.**
*   **Generate a report similar to the classroom setup.**

## 5. Update Documentation

The `README.md` file will be updated to include instructions on how to use the new `just user-up` command.
