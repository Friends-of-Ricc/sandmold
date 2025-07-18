# si chiamerebbe bootstrap-0
module "project" {
  source          = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project"
  billing_account = var.billing_account
  name            = "0"
  # prendi folder da modulo classe se la vuoi creare qui
  parent = module.folder.id
  prefix = var.prefix
  services = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "serviceusage.googleapis.com"
  ]
  # iam_by_principals = {
  #   (local.attendee_iam_emails[each.key]) = [
  #     "roles/browser",
  #     "roles/iap.tunnelResourceAccessor",
  #     "roles/compute.instanceAdmin.v1",
  #     "roles/compute.networkAdmin",
  #     "roles/compute.securityAdmin",
  #     "roles/iam.serviceAccountUser",
  #     "roles/viewer"
  #   ]
  # }
}

module "bucket-tf-state" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/gcs"
  project_id = var.project_id
  prefix     = var.prefix
  name       = "tf-state"
  location   = "EU"
  versioning = true
  labels = {
    cost-center = "devops"
  }
  iam_bindings = var.use_sa ? {
    bucket_key_iam = {
      members = [module.iac-sa.iam_email]
      role    = "roles/storage.objectUser"
    }
  } : null
}

module "iac-sa" {
  source     = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/iam-service-account"
  project_id = var.project_id
  name       = "iac-sa"
  # authoritative roles granted *on* the service accounts to other identities
  iam = {
    # var.users è una lista di email --> ["ricc@...", "luca@..."]
    "roles/iam.serviceAccountTokenCreator" = var.users
  }
  # non-authoritative roles granted *to* the service accounts on other resources
  iam_project_roles = {
    "${var.project_id}" = [
      "roles/logging.logWriter",
      "roles/monitoring.metricWriter",
    ]
  }
}
