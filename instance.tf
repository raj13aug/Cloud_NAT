
data "google_compute_default_service_account" "default" {
  project = var.project_id
}


resource "google_compute_instance" "test-instance" {
  name         = "test-instance"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  metadata = {
    enable-guest-attributes = "TRUE"
    enable-osconfig         = "TRUE"
  }

  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }


  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
    }
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    sudo apt-get update
  EOF

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet-private.id
    access_config {}
  }
  tags = ["private-instance"]
}