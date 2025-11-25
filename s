[1;33mdiff --git a/GEMINI.md b/GEMINI.md[m
[1;33mindex 5c12757..0d2ca9a 100644[m
[1;33m--- a/GEMINI.md[m
[1;33m+++ b/GEMINI.md[m
[1;35m@@ -62,3 +62,7 @@[m [mIf users asks you to review https://github.com/Friends-of-Ricc/sandmold/issues/X[m
 4. Commit and add to the commit message the issue "https://github.com/Friends-of-Ricc/sandmold/issues/XXX".[m
 5. Open a Pull Request.[m
 6. Wait for user et al. to review it. When done, close the Merge request and add a final comment to the issue. We close it if we're done, otherwise we point out the next steps.[m
[1;32m+[m
[1;32m+[m[1;32m## Billing and ENV[m
[1;32m+[m
[1;32m+[m[1;32mCheck for BILLING_ACCOUNT_ID in `.env`.[m
[1;33mdiff --git a/README.md b/README.md[m
[1;33mindex c1ce00b..5db8033 100644[m
[1;33m--- a/README.md[m
[1;33m+++ b/README.md[m
[1;35m@@ -20,7 +20,7 @@[m [mTaxonomy:[m
 Sample app:[m
 [m
 [m
[1;31m-```[m
[1;32m+[m[1;32m```bash[m
 $ just classroom-inspect-sampleclass[m
 [...][m
 🌳 Exploring parent folder (1000371719973) in Org: 791852209422 (sredemo.dev)[m
[1;35m@@ -31,11 +31,12 @@[m [m$ just classroom-inspect-sampleclass[m
 │       ├── 🧩 ng1-std-p3-v7km (ng1-std-p3-v7km)[m
 │       └── 🧩 ng1-tch-teacherz-lvs6 (ng1-tch-teacherz-lvs6)[m
 ```[m
[1;32m+[m
 ## Supported apps[m
 [m
 We intend to support the most popular solutions like:[m
 * **Bank of Anthos** (aka BoA): https://github.com/GoogleCloudPlatform/bank-of-anthos[m
[1;31m-* **Online Boutique** (aka Heapster Shop): https://github.com/GoogleCloudPlatform/microservices-demo[m
[1;32m+[m[1;32m* **Online Boutique** (aka Online Boutique): https://github.com/GoogleCloudPlatform/microservices-demo[m
 [m
 The idea is that a class teacher can easily build scenario on top of existing blueprints.[m
 [m
[1;35m@@ -89,7 +90,6 @@[m [mTo troubleshoot:[m
 ## Owners[m
 [m
 * Riccardo `palladius`[m
[1;31m-* Leonid `minherz`[m
 [m
 Contributing: see `CONTRIBUTING.md`[m
 [m
[1;35m@@ -97,11 +97,11 @@[m [mContributing: see `CONTRIBUTING.md`[m
 [m
 ```mermaid[m
 erDiagram[m
[1;31m-    USER ||--o{ LAB : has[m
[1;31m-    LAB ||--o{ SEAT : contains[m
[1;31m-    LAB ||--o{ APP : deploys[m
[1;31m-    APP ||--o{ APP : depends_on[m
[1;31m-    SEAT ||--|{ USER : assigned_to[m
[1;32m+[m[1;32m    User ||--o{ Class : has[m
[1;32m+[m[1;32m    Class ||--o{ Seat : contains[m
[1;32m+[m[1;32m    Class ||--o{ App : deploys[m
[1;32m+[m[1;32m    App ||--o{ App : depends_on[m
[1;32m+[m[1;32m    Seat ||--|{ User : assigned_to[m
 ```[m
 [m
 ## Data Flow[m
[1;35m@@ -117,7 +117,10 @@[m [mThe core logic of Sandmold is built upon a modular Terraform structure. This des[m
 ## Implementation[m
 [m
 Check `IMPLEMENTATION.md` for current state of implementation.[m
[1;31m-_[X] Creation of folder-based[m
[1;32m+[m
[1;32m+[m[1;32m## Scripts[m
[1;32m+[m
[1;32m+[m[1;32mFor more on scripts functionality, check `doc/USER_MANUAL.md`[m
 [m
 ## Single User Setup[m
 [m
[1;35m@@ -137,3 +140,12 @@[m [mYou can test the YAML quality with `just test-yaml YOUR_CONFIG.yaml`.[m
 You can also do more interesting preflight checks like:[m
 [m
 ![preflight checks](doc/preflight-check-screenshot.png)[m
[1;32m+[m
[1;32m+[m[1;32m## Caveats[m
[1;32m+[m
[1;32m+[m[1;32m*   **Resource Recreation Delay:** When you delete Google Cloud resources like projects and folders, they go into a "soft delete" or "inactive" state for a period of time before being permanently purged. If you attempt to run `classroom-up` to recreate a classroom with the same name immediately after running `classroom-down`, you may encounter errors like "Requested entity already exists" or "The folder operation violates display name uniqueness".[m
[1;32m+[m
[1;32m+[m[1;32m    While the scripts attempt to mitigate this by adding a random suffix to folder names, the best practice to avoid these issues is to:[m
[1;32m+[m[1;32m    1.  Run `just classroom-down your-classroom.yaml` to delete the old environment.[m
[1;32m+[m[1;32m    2.  In your `your-classroom.yaml` file, change the `spec.folder.resource_prefix` to a new value.[m
[1;32m+[m[1;32m    3.  Run `just classroom-up your-classroom.yaml` to create the new environment. This ensures all generated resource names are completely new.[m
[1;33mdiff --git a/bin/classroom-down.sh b/bin/classroom-down.sh[m
[1;33mindex 86997ae..ffe65b9 100755[m
[1;33m--- a/bin/classroom-down.sh[m
[1;33m+++ b/bin/classroom-down.sh[m
[1;35m@@ -6,8 +6,18 @@[m [mset -o pipefail[m
 cd "$(git rev-parse --show-toplevel)"[m
 [m
 CLASSROOM_YAML="$1"[m
[1;32m+[m[1;32m# Use command-line arg for billing account, fallback to ENV, then error out.[m
[1;32m+[m[1;32mBILLING_ACCOUNT_ID="${2:-$BILLING_ACCOUNT_ID}"[m
[1;32m+[m[1;32mGCLOUD_USER=$(gcloud config get-value account --quiet)[m
 CLASSROOM_TF_DIR="iac/terraform/sandmold/1a_classroom_setup"[m
 [m
[1;32m+[m[1;32mif [ -z "$BILLING_ACCOUNT_ID" ]; then[m
[1;32m+[m[1;32m    echo "Error: Billing account ID not provided."[m
[1;32m+[m[1;32m    echo "Usage: $0 <classroom_yaml> [billing_account_id]"[m
[1;32m+[m[1;32m    echo "Alternatively, set the BILLING_ACCOUNT_ID environment variable."[m
[1;32m+[m[1;32m    exit 1[m
[1;32m+[m[1;32mfi[m
[1;32m+[m
 echo "--- Starting Classroom Teardown for ${CLASSROOM_YAML} in ${CLASSROOM_TF_DIR} ---"[m
 [m
 # Get the workspace name from the new schema[m
[1;35m@@ -26,7 +36,9 @@[m [muv run python ./bin/prepare_tf_vars.py \[m
     --classroom-yaml "${CLASSROOM_YAML}" \[m
     --project-config-yaml etc/project_config.yaml \[m
     --output-file "${TF_VARS_FILE}" \[m
[1;31m-    --project-root "$(pwd)"[m
[1;32m+[m[1;32m    --project-root "$(pwd)" \[m
[1;32m+[m[1;32m    --gcloud-user "${GCLOUD_USER}" \[m
[1;32m+[m[1;32m    --billing-account-id "${BILLING_ACCOUNT_ID}"[m
 [m
 RELATIVE_TF_VARS_FILE="workspaces/${WORKSPACE_NAME}/terraform.tfvars.json"[m
 [m
[1;33mdiff --git a/bin/classroom-up.sh b/bin/classroom-up.sh[m
[1;33mindex 2e1fec7..e124a92 100755[m
[1;33m--- a/bin/classroom-up.sh[m
[1;33m+++ b/bin/classroom-up.sh[m
[1;35m@@ -7,10 +7,13 @@[m [mcd "$(git rev-parse --show-toplevel)"[m
 [m
 CLASSROOM_YAML="$1"[m
 CLASSROOM_TF_DIR="$2"[m
[1;31m-BILLING_ACCOUNT_ID="$3"[m
[1;32m+[m[1;32m# Use command-line arg for billing account, fallback to ENV, then error out.[m
[1;32m+[m[1;32mBILLING_ACCOUNT_ID="${3:-$BILLING_ACCOUNT_ID}"[m
 [m
 if [ -z "$BILLING_ACCOUNT_ID" ]; then[m
[1;31m-    echo "Error: Billing account ID not provided. Usage: $0 <classroom_yaml> <terraform_dir> <billing_account_id>"[m
[1;32m+[m[1;32m    echo "Error: Billing account ID not provided."[m
[1;32m+[m[1;32m    echo "Usage: $0 <classroom_yaml> <terraform_dir> [billing_account_id]"[m
[1;32m+[m[1;32m    echo "Alternatively, set the BILLING_ACCOUNT_ID environment variable."[m
     exit 1[m
 fi[m
 [m
[1;33mdiff --git a/bin/prepare_tf_vars.py b/bin/prepare_tf_vars.py[m
[1;33mindex 861c781..f757a21 100755[m
[1;33m--- a/bin/prepare_tf_vars.py[m
[1;33m+++ b/bin/prepare_tf_vars.py[m
[1;35m@@ -28,6 +28,13 @@[m [mdef parse_yaml(file_path):[m
     with open(file_path, 'r') as f:[m
         return yaml.safe_load(f)[m
 [m
[1;32m+[m[1;32mimport random[m
[1;32m+[m[1;32mimport string[m
[1;32m+[m
[1;32m+[m[1;32mdef generate_random_suffix(length=4):[m
[1;32m+[m[1;32m    """Generates a random alphanumeric suffix."""[m
[1;32m+[m[1;32m    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=length))[m
[1;32m+[m
 def main(classroom_yaml_path, project_config_yaml_path, output_file, project_root, gcloud_user, billing_account_id):[m
     """[m
     Parses classroom and project configs and generates terraform.tfvars.json.[m
[1;35m@@ -103,7 +110,8 @@[m [mdef main(classroom_yaml_path, project_config_yaml_path, output_file, project_roo[m
     # Default folder display name to metadata name if not provided[m
     base_folder_display_name = folder_spec.get('displayName', metadata.get('name'))[m
     sanitized_gcloud_user = gcloud_user.replace('@', '-').replace('.', '-')[m
[1;31m-    folder_display_name = f"{prefix}{base_folder_display_name}-{sanitized_gcloud_user}" if sanitized_gcloud_user else f"{prefix}{base_folder_display_name}"[m
[1;32m+[m[1;32m    random_suffix = generate_random_suffix()[m
[1;32m+[m[1;32m    folder_display_name = f"{prefix}{base_folder_display_name}-{sanitized_gcloud_user}-{random_suffix}" if sanitized_gcloud_user else f"{prefix}{base_folder_display_name}-{random_suffix}"[m
 [m
     parent_folder_id = os.getenv('PARENT_FOLDER_ID')[m
     parent = f"folders/{parent_folder_id}" if parent_folder_id else f"organizations/{organization_id}"[m
[1;33mdiff --git a/iac/terraform/sandmold/1a_classroom_setup/workspaces/ng2teachers-4realstudents/REPORT.md b/iac/terraform/sandmold/1a_classroom_setup/workspaces/ng2teachers-4realstudents/REPORT.md[m
[1;33mindex 9127bf6..b8bb50e 100644[m
[1;33m--- a/iac/terraform/sandmold/1a_classroom_setup/workspaces/ng2teachers-4realstudents/REPORT.md[m
[1;33m+++ b/iac/terraform/sandmold/1a_classroom_setup/workspaces/ng2teachers-4realstudents/REPORT.md[m
[1;35m@@ -1,12 +1,12 @@[m
 # 🌪️ Classroom Destroyed 🌪️[m
 [m
[1;31m-**Timestamp:** 2025-07-22 08:59:20[m
[1;32m+[m[1;32m**Timestamp:** 2025-10-08 16:35:46[m
 [m
 ## Class Details[m
 [m
 - **Workspace Name:** `ng2teachers-4realstudents`[m
 - **Original Folder Name:** None[m
[1;31m-- **Original Folder ID:** 194703823593[m
[1;32m+[m[1;32m- **Original Folder ID:** None[m
 - **Description:** Class with 3 teachers and 4 real students[m
 [m
 ## ⚡ Handy Commands[m
[1;33mdiff --git a/iac/terraform/sandmold/1a_classroom_setup/workspaces/ng2teachers-4realstudents/terraform.tfvars.json b/iac/terraform/sandmold/1a_classroom_setup/workspaces/ng2teachers-4realstudents/terraform.tfvars.json[m
[1;33mindex 3855348..64ab660 100644[m
[1;33m--- a/iac/terraform/sandmold/1a_classroom_setup/workspaces/ng2teachers-4realstudents/terraform.tfvars.json[m
[1;33m+++ b/iac/terraform/sandmold/1a_classroom_setup/workspaces/ng2teachers-4realstudents/terraform.tfvars.json[m
[1;35m@@ -1,7 +1,8 @@[m
 {[m
[1;31m-  "folder_display_name": "ng2teachers-4realstudents",[m
[1;31m-  "parent_folder": "folders/194703823593",[m
[1;32m+[m[1;32m  "folder_display_name": "ng2teachers-4realstudents-ricc-google-com-zzim",[m
[1;32m+[m[1;32m  "parent_folder": "folders/665877171749",[m
   "billing_account_id": "01C588-4823BC-27F650",[m
[1;32m+[m[1;32m  "organization_id": "337847326365",[m
   "teachers": [[m
     "user:riccardo@example.com",[m
     "user:leonie@example.com",[m
[1;33mdiff --git a/justfile b/justfile[m
[1;33mindex 9a33d44..5c92dc3 100644[m
[1;33m--- a/justfile[m
[1;33m+++ b/justfile[m
[1;35m@@ -41,7 +41,7 @@[m [mclassroom-up-sampleclass:[m
 [m
 # Teardown a classroom environment[m
 classroom-down CLASSROOM_YAML:[m
[1;31m-    time bin/classroom-down.sh {{CLASSROOM_YAML}}[m
[1;32m+[m[1;32m    time bin/classroom-down.sh {{CLASSROOM_YAML}} {{BILLING_ACCOUNT_ID}}[m
 [m
 # Setup a single-user environment[m
 user-up USER_YAML='etc/samples/single_user/light.yaml':[m
