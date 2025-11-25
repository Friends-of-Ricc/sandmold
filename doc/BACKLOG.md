# 📝 Project Backlog

This file contains a list of planned features, enhancements, and refactoring tasks for the Sandmold project.

---

## 🚀 Service Account for Automation

### 🤔 **The Why (Rationale)**

Currently, all operations (`terraform apply`, `gcloud` commands) are run using a personal user account (e.g., `user1@example.com` or `user2@example.com`). While this is fine for initial development, it's not ideal for security or long-term automation.

Using a dedicated **Service Account** provides several key advantages:
-   🔐 **Enhanced Security:** We avoid using powerful personal user credentials in automated scripts. The Service Account has its own credentials (a JSON key file) that can be securely managed and rotated.
-   ⚙️ **Principle of Least Privilege:** We can grant the Service Account *only* the exact IAM permissions it needs to do its job (e.g., create projects, manage folders, link billing). This is much safer than using a user account that might have broad "Organization Admin" powers.
-   🤖 **Automation Ready:** Service Accounts are designed for non-interactive use in scripts and CI/CD pipelines. This will be essential when we want to run classroom setups automatically.

### ✅ **The What (Implementation Plan)**

1.  **Create Service Account:**
    -   Create a new Service Account within the `sredemo.dev` organization. A good name would be `sandmold-automator@<your-project>.iam.gserviceaccount.com`.
2.  **Grant IAM Permissions:**
    -   Grant the new Service Account the following roles on the appropriate resources:
        -   `roles/resourcemanager.folderAdmin` on the parent folder (e.g., `123456789012`).
        -   `roles/resourcemanager.projectCreator` on the parent folder (`1000371719973`).
        -   `roles/billing.user` on the chosen billing account.
3.  **Update Scripts & Workflow:**
    -   Modify the `justfile` and the core shell scripts (`setup-classroom.sh`, `teardown-classroom.sh`, `preflight-checks.py`) to use the Service Account.
    -   This will likely involve using a JSON key file and authenticating via `gcloud auth activate-service-account --key-file=<path-to-key.json>`. We will need a secure way to manage this key.
4.  Add `sandmold-automator` test to the preflight check. Since name is deterministic, we cna check if it's there or not.

