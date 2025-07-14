# iac/terraform/modules/project/outputs.tf

output "project_id" {
  description = "The final ID of the project."
  value       = local.project.project_id
}

output "project_number" {
  description = "The unique numeric identifier for the project."
  value       = local.project.number
}
