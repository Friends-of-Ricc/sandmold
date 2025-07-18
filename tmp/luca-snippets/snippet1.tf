# Terraform
module "projects" {
  for_each = var.my_prefixes
  source   = "../genai-factory/cloud-run-single/0-projects"
  project_config = {
    billing_account_id = "XXXXXXXXX"
    parent             = "folders/my-folder"
    prefix             = each.key
  }
}

module "apps" {
  for_each = var.my_prefixes
  source   = "../genai-factory/cloud-run-single/1-apps"
  lbs_config = {
    external = {
      domain = "${each.key}.ricc.com"
    }
  }
}

variable "my_prefixes" {
  description = "My project prefixes"
  type        = list(string)
  default     = ["one", "two", "three"]
}

