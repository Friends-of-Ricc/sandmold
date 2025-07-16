## FR002 Ensure cute labels

* For all classrooms, ensure some labels are created: "sandmold"
* For teacher seat, ensure a label like "teacher"
* For student seat, ensure a label like "student".

## Implementation

To implement this feature, the following changes were made:

1.  **`bin/prepare_tf_vars.py` was modified:**
    *   It now automatically adds a static label `sandmold: "true"` to the `folder_tags` variable.
    *   For each project, it adds a `labels` dictionary containing a `desk-type` key, with a value of either `teacher` or `student`.

2.  **`iac/terraform/1a_classroom_setup/main.tf` was updated:**
    *   The `google_folder` resource was updated to use the `var.folder_tags` to set its `labels`.
    *   The `module "project"` block was updated to pass the new `labels` map to the project module for each project being created.

3.  **The `iac/terraform/modules/project/` module was updated:**
    *   `variables.tf` was modified to include a new `labels` variable of type `map(string)`.
    *   `main.tf` was modified to apply the `var.labels` map to the `google_project` resource.