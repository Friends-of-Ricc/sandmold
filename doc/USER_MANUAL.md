# Sandmold User Manual

This document provides a high-level overview of the key scripts used to manage classroom environments in the Sandmold project.

## Core Scripts

These are the main scripts that perform the creation and destruction of Google Cloud resources.

### `bin/classroom-up.sh`

This is the primary script for creating a complete classroom environment. It takes a classroom definition YAML file and a billing account ID as input and provisions all the necessary cloud resources (folders, projects, permissions) as defined in the Terraform configuration.

Under the hood, it performs several key steps. First, it calls the `prepare_tf_vars.py` helper script to translate the human-readable YAML file into a `terraform.tfvars.json` file that Terraform can understand. It then navigates to the correct Terraform directory, initializes Terraform, selects a unique workspace based on the classroom name, and finally runs `terraform apply` to create the resources in Google Cloud.

### `bin/classroom-down.sh`

This script is the counterpart to `classroom-up.sh` and is used to destroy all the resources associated with a specific classroom environment. It also requires the classroom YAML file and the billing account ID to identify which resources to remove.

To ensure it can run reliably and independently, this script also calls `prepare_tf_vars.py` to generate the `terraform.tfvars.json` file. This step is crucial because it allows the script to know exactly what needs to be destroyed, even if the original output from the `classroom-up` command was lost. After generating the variables file, it runs `terraform destroy` to safely remove all associated resources from Google Cloud.

## Helper Scripts & Commands

### `bin/prepare_tf_vars.py`

This Python script acts as a bridge between the user-friendly classroom YAML files and Terraform. Its sole purpose is to read the `spec` and `metadata` from a given classroom YAML, combine it with project-wide configurations (like default labels and services to enable), and generate a structured `terraform.tfvars.json` file.

This generated JSON file is then used by Terraform to populate the variables in the `.tf` configuration files, ensuring that the created resources match the specifications in the classroom definition.

### `just` commands (`just classroom-up`, `just classroom-down`)

These are convenient wrappers defined in the project's `justfile`. They provide a simpler, more user-friendly way to execute the core shell scripts.

The main advantage of using the `just` commands is that they automatically source the `BILLING_ACCOUNT_ID` from your `.env` file, so you don't have to type it on the command line every time. They call the underlying `.sh` scripts with the correct arguments, making the day-to-day workflow for managing classrooms much more efficient.
