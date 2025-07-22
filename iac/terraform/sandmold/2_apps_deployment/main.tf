output "app_deployments_details" {
  description = "Details for deploying applications, including project_id, app_name, and environment variables."
  value = {
    for i, app in var.app_deployments : i => {
      project_id  = app.project_id
      app_name    = app.app_name
      environment = app.environment
      working_dir = abspath("${path.module}/../../../applications/${app.app_name}")
      start_script = abspath("${path.module}/../../../applications/${app.app_name}/start.sh")
    } if app.status == "OK"
  }
  sensitive = true # Mark as sensitive to avoid printing secrets to the console
}