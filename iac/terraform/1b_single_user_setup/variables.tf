# iac/terraform/1b_single_user_setup/variables.tf

variable "create_project" {
  description = "Set to 'false' if you are using an existing GCP project."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "The ID for your project. If creating a new one, a random suffix will be added."
  type        = string
}

variable "billing_account_id" {
  description = "The billing account ID to link to the project."
  type        = string
  sensitive   = true
}

variable "user_email" {
  description = "Your Google Cloud email address (e.g., 'your-name@gmail.com')."
  type        = string
}
