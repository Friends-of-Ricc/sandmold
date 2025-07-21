# iac/saas-runtime/terraform-classroom-folder/main.tf

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.50.0"
    }
  }
}

# Create the main folder for the classroom
resource "google_folder" "classroom" {
  display_name = "classroom-folder-for-${var.teacher_email}"
  parent       = var.parent_folder
}

# Grant folder-level permissions to teachers
resource "google_folder_iam_member" "teacher_permissions" {
  folder   = google_folder.classroom.folder_id
  role     = "roles/owner"
  member   = "user:${var.teacher_email}"
}
