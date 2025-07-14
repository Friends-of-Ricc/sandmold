# iac/terraform/1a_classroom_setup/variables.tf

variable "folder_name" {
  description = "The name of the Google Cloud Folder to create."
  type        = string
}

variable "parent_folder" {
  description = "The parent resource for the folder, e.g., 'folders/12345' or 'organizations/67890'."
  type        = string
}

variable "billing_account_id" {
  description = "The billing account ID to link to the created projects."
  type        = string
  sensitive   = true
}

variable "teachers" {
  description = "A list of teacher emails to grant owner access to the folder."
  type        = list(string)
  default     = []
}

variable "student_projects" {
  description = "A list of objects representing the projects to create for students."
  type = list(object({
    project_id_prefix = string
    users             = list(string)
  }))
  default = []
}

variable "services_to_enable" {
  description = "A list of Google Cloud APIs to enable on each project."
  type        = list(string)
  default     = []
}

variable "iam_user_roles" {
  description = "A list of IAM roles to grant to the users of each project."
  type        = list(string)
  default     = []
}

variable "folder_tags" {
  description = "A map of tags to apply to the folder."
  type        = map(string)
  default     = {}
}
