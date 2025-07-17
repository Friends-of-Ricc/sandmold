# iac/terraform/2_apps_deployment/main.tf

terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

locals {
  app_deployment_config = jsondecode(var.app_deployment_json)
  apps = flatten([
    for project in local.app_deployment_config.projects : [
      for app in project.apps : {
        project_id = project.project_id
        desk_type  = project.desk_type
        app_name   = app.name
        app_path   = app.path
        malformed  = app.malformed
      }
    ]
  ])
}

resource "null_resource" "app_deployment" {
  for_each = { for app in local.apps : "${app.project_id}-${app.app_name}" => app }

  triggers = {
    app_name = each.value.app_name
  }

  provisioner "local-exec" {
    command = <<EOT
      if [ "${each.value.malformed}" = "false" ]; then
        echo "Deploying app ${each.value.app_name} to project ${each.value.project_id}"
        ${each.value.app_path}/start.sh
      else
        echo "Skipping deployment of malformed app: ${each.value.app_name}"
      fi
    EOT
    environment = {
      GOOGLE_CLOUD_PROJECT = each.value.project_id
      SANDMOLD_DESK_TYPE   = each.value.desk_type
    }
  }
}
