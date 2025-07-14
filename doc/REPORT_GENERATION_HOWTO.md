# How to Manually Generate the Classroom Report

This guide explains how to regenerate the final `REPORT.md` for a classroom environment at any time, without needing to run the full `terraform apply` again.

This is useful if you want to get a fresh summary of the provisioned resources after making manual changes or if the report file was accidentally deleted.

The process relies on two key ingredients:
1.  The **Terraform state file** (`terraform.tfstate`), which is the source of truth for what exists in the cloud.
2.  The **classroom YAML file**, which contains the original intent and metadata (like user and application names).

---

### Step 1: Navigate to the Classroom Terraform Directory

All commands that query the state of your infrastructure must be run from the directory containing the corresponding `.tfstate` file.

```bash
cd iac/terraform/1a_classroom_setup/
```

### Step 2: Generate the Terraform Output JSON

Run the `terraform output` command with the `-json` flag. This reads the state file and prints all the output variables in a machine-readable format.

We redirect this output into a file in the repository's root directory.

```bash
terraform output -json > ../../../terraform_output.json
```

### Step 3: Navigate Back to the Root Directory

The reporting script is designed to be run from the root of the repository.

```bash
cd ../../../
```

### Step 4: Run the Report Generation Script

Execute the `generate_report.py` script. You must provide it with the path to the JSON file we just created and the path to the original classroom YAML file that was used for the setup.

```bash
./bin/generate_report.py \
    --tf-output-json terraform_output.json \
    --classroom-yaml etc/class_2teachers_6students.yaml \
    --report-path REPORT.md
```

And that's it! A fresh `REPORT.md` has been generated in the root of your repository.

```