variable "region" {
  description = "The Google Cloud region"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "The Google Cloud zone"
  type        = string
  default     = "europe-west1-a"
}

variable "instance_name" {
  description = "Name for the Compute Engine instance"
  type        = string
#  default = "saas-runtime-vm-instance"
  default = "saas-vm-ricc02"
}

variable "machine_type" {
  description = "Machine type for the Compute Engine instance"
  type        = string
  default = "e2-medium"
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default = 10
}

variable "actuation_sa" {
  description = "The email of the Actuation Service Account"
  type        = string
}

variable "tenant_project_id" {
  description = "The project ID of the tenant project"
  type        = string
}

variable "tenant_project_number" {
  description = "The project number of the tenant project"
  type        = number
}
