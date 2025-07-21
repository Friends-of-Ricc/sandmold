output "instance_name" {
  description = "Name of the instance"
  value       = google_compute_instance.vm_instance.name
}

output "instance_external_ip" {
  description = "External IP of the instance"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "instance_self_link" {
  description = "Self-link of the instance"
  value       = google_compute_instance.vm_instance.self_link
}
