module "classroom_setup" {
  source = "./1a_classroom_setup"

  folder_display_name = var.folder_display_name
  parent_folder       = var.parent_folder
  billing_account_id  = var.billing_account_id
  teachers            = var.teachers
  student_projects    = var.student_projects
  services_to_enable  = var.services_to_enable
  iam_user_roles      = var.iam_user_roles
  folder_tags         = var.folder_tags
}

module "apps_deployment" {
  source = "./2_apps_deployment"

  app_deployments = var.app_deployments
  projects = module.classroom_setup.projects
  depends_on = [module.classroom_setup]
}
