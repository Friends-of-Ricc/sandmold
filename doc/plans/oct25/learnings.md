# Learnings from Terraform Apply - Oct 25

This document captures the errors, learnings, and fixes encountered during the execution of the `terraform apply` process on October 25th.

## Initial Failures and Resolutions

1.  **Missing Billing Account ID:** The `classroom-up.sh` script initially failed because it was called without the required billing account ID.
    *   **Fix:** The script was re-run with a valid billing account ID.

2.  **Incorrect Terraform Directory:** The script failed with a "No configuration files" error.
    *   **Learning:** The second argument to `classroom-up.sh` must be a directory containing Terraform files, not just a prefix for a workspace.
    *   **Fix:** The `just classroom-up` command was used, which correctly points to `iac/terraform/sandmold/1a_classroom_setup`.

3.  **Authentication Error:** The `terraform apply` command failed with an OAuth `invalid_grant` error.
    *   **Fix:** Ran `just auth` to refresh the local `gcloud` credentials.

4.  **Billing Account Constraint:** The `terraform apply` failed with a `constraints/billing.outsideGoogleBillingMdbWhitelist` error.
    *   **Learning:** The initial billing account was an internal Google account and could not be used for this purpose.
    *   **Fix:** Switched to a trial billing account (`01C588-4823BC-27F650`).

5.  **Pre-existing Projects:** Subsequent `terraform apply` runs failed with "Requested entity already exists" errors.
    *   **Learning:** Failed `apply` runs can leave behind "zombie" projects that are in the process of being deleted but still cause conflicts.
    *   **Fix:** Ran `just classroom-down` to clean up the environment. This also required fixing a bug in the `classroom-down.sh` script.

6.  **Folder Name Uniqueness:** The `terraform apply` failed with a "display name uniqueness" error for the folder.
    *   **Learning:** Recently deleted folders can't be immediately recreated with the same name.
    *   **Fix:** Modified the `prepare_tf_vars.py` script to add a random suffix to the folder display name, ensuring it's always unique.

## Final Roadblock

*   **Billing Quota Exceeded:** The final `terraform apply` attempt failed with a "Cloud billing quota exceeded" error.
    *   **Conclusion:** The trial billing account has a limit on the number of projects it can be associated with. This is a hard limit that cannot be resolved through code changes. Further attempts to provision this classroom will require a different billing account with a higher project limit.
