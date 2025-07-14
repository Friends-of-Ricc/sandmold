# Summary of Work Done

Here is a summary of the tasks we accomplished together in this session.

## Terraform Setup & Troubleshooting

Our initial goal was to run `terraform` in the `0-projects/` directory. We encountered and resolved several initial setup issues:

1.  **Terraform Version Incompatibility:** Diagnosed that the installed Terraform version (`1.7.4`) was too old for the project's modules.
2.  **Local Terraform Installation:** To avoid system-wide changes, we downloaded a compatible Terraform version (`1.12.2`), stored it in a local `.bin/` directory, and used a `justfile` to create convenient aliases (`init`, `plan`, `apply`).

## GCP Permissions & Policy Troubleshooting

This was the most complex part of our session. We systematically worked through several layers of GCP permissions to enable the Terraform deployment.

1.  **Authentication:** Resolved an initial `invalid_grant` OAuth error by re-authenticating your `ricc@google.com` user with `gcloud`.
2.  **Billing Account Permissions:** Encountered `billing.resourceAssociations.create` errors. We discovered you lacked permissions on the first two billing accounts we tried.
3.  **Finding a Valid Billing Account:** We developed a strategy to find a usable billing account.
    *   We first tried an internal Google account which was blocked by an Organization Policy (`constraints/billing.outsideGoogleBillingMdbWhitelist`).
    *   We then tested a "Trial" account, which was valid but not currently active (`open = False`).
    *   Finally, you created a new personal billing account (`01C588-4823BC-27F650`), and I guided you on how to grant your corporate user (`ricc@google.com`) the necessary `roles/billing.user` permission.
4.  **Folder Permissions:** We resolved a `resourcemanager.projects.create` error by granting your user the `Project Creator` role on the target folder (`1000371719973`).
5.  **Project ID Conflicts:** We resolved several `Error 409: Requested entity already exists` errors by incrementing a `prefix` variable in the `terraform.tfvars` file, ensuring a unique project ID for each deployment attempt.

## Successful Deployment

With all permissions and a valid billing account in place, we successfully ran `just apply` to deploy the project `ricc-tf-4-gf-srun-0` and its 67 associated resources.

## GCP Folder & IAM Management via Scripting

After the deployment, we moved on to managing GCP resources directly.

1.  **Folder Creation:** You asked me to create 5 subfolders within the `test-sandmold` folder (`1000371719973`). I created a reusable bash script, `create_subfolders.sh`, to accomplish this.
2.  **Granting Permissions:** To grant specific permissions to your colleague `leoy@google.com`, I created a second script, `grant_leoy_permissions.sh`. This script:
    *   Grants `Viewer` and `Browser` roles on the `sredemo.dev` organization (`791852209422`).
    *   Grants `Viewer` and `Browser` roles on the parent `test-sandmold` folder.
    *   Grants `Folder Admin` role on the five `test-sandmold-leoy-XXX` subfolders.
    *   We also debugged this script, correcting an invalid IAM role from `folderOwner` to `folderAdmin`.

## Cleanup & Finalization

To conclude the session:

1.  **Script Organization:** We moved the two bash scripts to `~/git/sandmold/bin/` for better organization.
2.  **Resource Teardown:** We added a `destroy` recipe to the `justfile` and successfully tore down all Terraform-managed resources, cleaning up the project.

---

### Final Scripts

<details>
<summary><code>create_subfolders.sh</code></summary>

```bash
#!/bin/bash

# Set the parent folder ID
PARENT_FOLDER="1000371719973"

# Get the display name of the parent folder
PARENT_FOLDER_NAME=$(gcloud resource-manager folders describe "$PARENT_FOLDER" --format="value(displayName)")

echo "Parent folder name is: $PARENT_FOLDER_NAME"
echo "Creating 5 subfolders under parent folder $PARENT_FOLDER ($PARENT_FOLDER_NAME)..."

for i in {1..5}
do
  gcloud resource-manager folders create \
    --display-name="test-sandmold-$i" \
    --folder="$PARENT_FOLDER"
done

echo "Script finished."
```
</details>

<details>
<summary><code>grant_leoy_permissions.sh</code></summary>

```bash
#!/bin/bash

# This script grants permissions to a user for a specific folder hierarchy.

# --- Configuration ---
ORGANIZATION_ID="791852209422"
PARENT_FOLDER_ID="1000371719973"
USER_EMAIL="leoy@google.com"
SUBFOLDER_NAME_PATTERN="test-sandmold-leoy-"

# --- Step 1: Grant Viewer and Browser roles on the organization ---
echo "Granting Viewer and Browser roles on organization $ORGANIZATION_ID to $USER_EMAIL..."
gcloud organizations add-iam-policy-binding "$ORGANIZATION_ID" --member="user:$USER_EMAIL" --role="roles/viewer" > /dev/null
gcloud organizations add-iam-policy-binding "$ORGANIZATION_ID" --member="user:$USER_EMAIL" --role="roles/browser" > /dev/null
echo "Done."
echo

# --- Step 2: Grant Viewer and Browser roles on the parent folder ---
echo "Granting Viewer and Browser roles on parent folder $PARENT_FOLDER_ID to $USER_EMAIL..."
gcloud resource-manager folders add-iam-policy-binding "$PARENT_FOLDER_ID" --member="user:$USER_EMAIL" --role="roles/viewer" > /dev/null
gcloud resource-manager folders add-iam-policy-binding "$PARENT_FOLDER_ID" --member="user:$USER_EMAIL" --role="roles/browser" > /dev/null
echo "Done."
echo

# --- Step 3: Grant Folder Admin role on specific subfolders ---
echo "Finding subfolders matching '$SUBFOLDER_NAME_PATTERN'..."
SUBFOLDER_IDS=$(gcloud resource-manager folders list --folder="$PARENT_FOLDER_ID" --filter="displayName~$SUBFOLDER_NAME_PATTERN" --format="value(ID)")

if [ -z "$SUBFOLDER_IDS" ]; then
  echo "No subfolders found matching the pattern '$SUBFOLDER_NAME_PATTERN'."
  exit 1
fi

echo "Found subfolders. Granting Folder Admin role to $USER_EMAIL..."
for FOLDER_ID in $SUBFOLDER_IDS; do
  FOLDER_NAME=$(gcloud resource-manager folders describe "$FOLDER_ID" --format="value(displayName)")
  echo "  - Granting admin on folder $FOLDER_ID ($FOLDER_NAME)..."
  gcloud resource-manager folders add-iam-policy-binding "$FOLDER_ID" --member="user:$USER_EMAIL" --role="roles/resourcemanager.folderAdmin" > /dev/null
done

echo
echo "All permissions have been granted successfully."
```
</details>

```