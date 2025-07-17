terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
    null = {
      source = "hashicorp/null"
      version = ">= 2.1"
    }
  }
}

resource "null_resource" "app_deployment" {
  for_each = { for i, app in var.app_deployments : i => app if app.status == "OK" }

  triggers = {
    project_id = each.value.project_id
    app_name   = each.value.app_name
  }

  provisioner "local-exec" {
    command     = "./start.sh"
    working_dir = abspath("${path.root}/../../applications/${each.value.app_name}")
    environment = each.value.environment
  }
}
