# How to Manually Generate a Classroom Report

This guide explains how to regenerate the final `REPORT.md` for a specific classroom environment at any time.

This is useful if you want to get a fresh summary of the provisioned resources after making manual changes or if the report file was accidentally deleted. All artifacts for a given classroom are stored in a dedicated **workspace directory**.

---

### The Generated Report

The final `REPORT.md` is a comprehensive summary of the provisioned classroom, designed to be user-centric. It includes:

*   **Class Details:** A new, clearer title for the main section.
*   **Folder Permalink:** A clickable link to the newly created Google Cloud Folder in the console.
*   **User-Centric View:** A table mapping each student (teachers are excluded) to their assigned project and applications. The project ID is a direct link to that project in the Google Cloud Console.
*   **TODO Section:** A clear list of next steps, such as how to proceed with installing the applications onto the student projects.

---

### Step 1: Identify the Classroom Workspace

All commands must be run relative to the repository root. First, identify the name of the classroom you want to generate a report for (this comes from the `metadata.name` field in your YAML file).

The workspace directory will be located at:
`iac/terraform/1a_classroom_setup/workspaces/<classroom_name>/`

For this example, we'll use `class-2teachers-6students`.

### Step 2: Generate the Terraform Output JSON

Run the `terraform output` command from within the Terraform directory, telling it which workspace to use. This reads the state file and prints all the output variables in a machine-readable format.

We redirect this output into the correct workspace directory.

```bash
(cd iac/terraform/1a_classroom_setup/ && terraform workspace select class-2teachers-6students && terraform output -json > workspaces/class-2teachers-6students/terraform_output.json)
```

### Step 3: Run the Report Generation Script

Execute the `generate_report.py` script from the repository root. You must provide it with the path to the JSON output file and the original classroom YAML. The report will be generated in the same workspace directory.

```bash
./bin/generate_report.py \
    --tf-output-json iac/terraform/1a_classroom_setup/workspaces/class-2teachers-6students/terraform_output.json \
    --classroom-yaml etc/samples/class_2teachers_6students.yaml \
    --report-path iac/terraform/1a_classroom_setup/workspaces/class-2teachers-6students/REPORT.md
```

And that's it! A fresh `REPORT.md` has been generated in the classroom's dedicated workspace directory.

```