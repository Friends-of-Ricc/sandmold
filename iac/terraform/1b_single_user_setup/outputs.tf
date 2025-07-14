# iac/terraform/1b_single_user_setup/outputs.tf

output "projects" {
  description = "A map of the created project, with the project ID as the key."
  value = {
    (module.project.project_id) = {
      project_id     = module.project.project_id
      project_number = module.project.project_number
    }
  }
}
