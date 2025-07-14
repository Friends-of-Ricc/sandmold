# iac/terraform/1a_classroom_setup/outputs.tf

output "projects" {
  description = "A map of the created projects, with the project ID as the key."
  value = {
    for key, proj in module.project : key => {
      project_id     = proj.project_id
      project_number = proj.project_number
    }
  }
}

output "folder_id" {
  description = "The ID of the created classroom folder."
  value       = google_folder.classroom.folder_id
}
