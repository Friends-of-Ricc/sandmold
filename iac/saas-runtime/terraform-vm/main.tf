resource "google_compute_instance" "vm_instance" {
  project      = var.tenant_project_id
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = var.disk_size
    }
  }

  network_interface {
    network = "default"
    access_config {
      # Ephemeral public IP - empty block is okay here
    }
  }

  tags = ["allow-ssh"]
}
