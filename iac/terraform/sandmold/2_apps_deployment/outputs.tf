# iac/terraform/sandmold/2_apps_deployment/outputs.tf

output "online_boutique_deployments" {
  description = "A map of the created Online Boutique GKE clusters."
  value = {
    for key, mod in module.online_boutique : key => {
      project_id       = mod.project_id
      cluster_name     = mod.cluster_name
      cluster_location = mod.cluster_location
    }
  }
}
