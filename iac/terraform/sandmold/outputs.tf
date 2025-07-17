output "projects" {
  description = "The projects that were created."
  value       = module.classroom_setup.projects
}

output "folder_id" {
  description = "The ID of the created classroom folder."
  value       = module.classroom_setup.folder_id
}
