# iac/saas-runtime/terraform-classroom-folder/outputs.tf

output "folder_id" {
  description = "The ID of the created classroom folder."
  value       = google_folder.classroom.folder_id
}
