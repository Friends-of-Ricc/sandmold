variable "projects_configs" {
  type = map(object({
    students    = list(string)
    labels      = map(string)
    description = 
  }))
  default = {
    project-1 = {
      labels = {
        env        = "dev"
        created-by = "sandmod"
      }
      students = ["ricc@google.com", "lucaprete@google.com"]
    }
  }
}
