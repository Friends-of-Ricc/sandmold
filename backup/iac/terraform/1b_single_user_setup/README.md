# Single User Project Setup (CUJ002)

This Terraform configuration allows a single user to provision a Google Cloud project with all the necessary APIs and permissions for the labs in this repository.

## Instructions

### 1. Prerequisites

*   You have installed the [Google Cloud CLI](https://cloud.google.com/sdk/docs/install).
*   You have installed [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli).
*   You have authenticated with Google Cloud: `gcloud auth application-default login`

### 2. Create your Configuration File

Create a file named `terraform.tfvars` in this directory (`iac/terraform/1b_single_user_setup/`).

### 3. Configure for a **New** Project

Copy the following into your `terraform.tfvars` file and fill in the values:

```hcl
# The ID you want for your new project. A random suffix will be added.
project_id = "my-sandmold-project"

# Your GCP billing account ID.
billing_account_id = "012345-ABCDEF-GHIJKL"

# The email address you use for Google Cloud.
user_email = "your-name@example.com"

# The parent for your project, e.g., "organizations/1234567890".
# You can find this in the GCP console.
parent = "organizations/YOUR_ORG_ID"
```

### 4. Configure for an **Existing** Project

If you already have a project you want to use, copy the following into your `terraform.tfvars` file instead:

```hcl
# Tell Terraform not to create a new project.
create_project = false

# The exact ID of your existing project.
project_id = "my-existing-project-123"

# Your GCP billing account ID.
billing_account_id = "012345-ABCDEF-GHIJKL"

# The email address you use for Google Cloud.
user_email = "your-name@example.com"
```

### 5. Run Terraform

Once your `terraform.tfvars` file is saved, run the following commands from this directory:

```bash
terraform init
terraform apply
```

Terraform will show you a plan and ask for confirmation before making any changes to your Google Cloud account.
