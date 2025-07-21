# iac/saas-runtime/terraform-classroom-folder/variables.tf

variable "parent_folder" {
  description = "The parent resource for the folder, e.g., 'folders/12345' or 'organizations/67890'."
  type        = string
}

variable "teacher_email" {
  description = "The email of the teacher to grant owner access to the folder."
  type        = string
  default = "ricc@google.com"
}
