# iac/terraform/modules/project/variables.tf

variable "create_project" {
  description = "If true, create a new project. If false, use a data source."
  type        = bool
  default     = true
}

variable "project_id" {
  description = "The desired project ID. A random suffix is appended if create_project is true."
  type        = string
}

variable "billing_account_id" {
  description = "The billing account to link to the project."
  type        = string
  sensitive   = true
}

variable "parent" {
  description = "The resource to create the project under (e.g., 'folders/12345')."
  type        = string
}

variable "services_to_enable" {
  description = "A list of APIs to enable on the project."
  type        = list(string)
  default     = []
}

variable "iam_permissions" {
  description = "A map where keys are roles and values are lists of members."
  type        = map(list(string))
  default     = {}
}

variable "labels" {
  description = "A map of labels to apply to the project."
  type        = map(string)
  default     = {}
}

