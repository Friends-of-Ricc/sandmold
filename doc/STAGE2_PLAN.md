# Plan for Application Deployment (Stage 2)

The current application deployment process is entangled with the infrastructure provisioning, causing failures and inefficiencies. This plan outlines a new, decoupled, and robust process for deploying applications to the classroom projects.

## 1. Decouple Application Deployment from Terraform

The `classroom-deploy-apps` command will no longer run `terraform apply`. Instead, it will focus solely on orchestrating the execution of application `start.sh` scripts.

## 2. Create a New `app-deploy.sh` Script

A new Bash script, `bin/app-deploy.sh`, will be created to handle the application deployment logic. This script will:

*   **Accept a classroom YAML file as input.**
*   **Parse the YAML to determine which applications to deploy to which projects.** This will be done by a helper script that extracts the necessary details.
*   **Execute `start.sh` scripts in parallel.** For each application in each project, a corresponding `applications/<app-name>/start.sh` script will be executed in the background.
*   **Capture structured logs and exit statuses.** For each deployment, the script will generate a JSON file with the following structure:
    ```json
    {
      "start_time": "YYYY-MM-DDTHH:MM:SSZ",
      "end_time": "YYYY-MM-DDTHH:MM:SSZ",
      "stdout": "...",
      "stderr": "...",
      "return_code": 0
    }
    ```
*   **Store logs in a persistent, organized location.** The log files will be stored in a new `app_logs` directory within the corresponding Terraform workspace. The path will be:
    `iac/terraform/1a_classroom_setup/workspaces/<workspace_name>/app_logs/<project_id_from_yaml>/<app_name>/start.lastlog.json`
    This structure ensures that:
    *   Logs are co-located with the Terraform state for the classroom.
    *   Logs are not affected by the randomized project ID suffixes.
    *   The `.lastlog` suffix indicates that the file is overwritten on each run.
*   **Provide a summary report.** After all deployments are complete, the script will parse the JSON log files and print a summary table indicating the status (success or failure) of each deployment.

## 3. Update the `justfile`

The `classroom-deploy-apps` recipe in the `justfile` will be updated to simply call the new `bin/app-deploy.sh` script.

## 4. Update `.gitignore`

A new entry, `**/app_logs/`, will be added to the root `.gitignore` file to prevent the application deployment logs from being committed to the repository.

## 5. (Optional) Enhance `start.sh` scripts

The existing `start.sh` scripts in the application directories will be reviewed and potentially updated to ensure they are idempotent and provide clear logging.