
data "google_compute_default_service_account" "default" {
  project = var.project_id
}

resource "google_project_iam_member" "osconfig_agent_role" {
  project = var.project_id
  role    = "roles/osconfig.guestPolicyAdmin"
  member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

resource "google_project_iam_member" "compute_instance_admin_role" {
  project = var.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

resource "google_compute_instance" "test-instance" {
  name                      = "test-instance"
  machine_type              = "e2-micro"
  zone                      = "us-central1-a"
  allow_stopping_for_update = true

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
    sudo apt-get install -y google-osconfig-agent
    sudo systemctl enable google-osconfig-agent
    sudo systemctl start google-osconfig-agent    
  EOF

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet-private.id
    access_config {}
  }
  tags = ["private-instance"]
}