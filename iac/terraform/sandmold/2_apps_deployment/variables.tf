# iac/terraform/sandmold/2_apps_deployment/variables.tf

variable "app_deployments" {
  description = "A list of objects describing the applications to be deployed."
  type        = any
  default     = []
}