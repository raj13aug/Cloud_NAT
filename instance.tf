resource "google_storage_bucket" "source" {
  name          = "my-bucket-curl-cloud7"
  location      = "us-east1"
  force_destroy = true
}


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
    sudo apt-get install -y curl gsutil
    echo "Hello, World!" > /tmp/hello.txt
    gsutil cp /tmp/hello.txt gs://my-bucket-curl-cloud7/
    echo "File transferred to GCS bucket!" > /tmp/transfer_status.txt
    curl -I http://google.com >> /tmp/transfer_status.txt
  EOF

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet-public.id
    access_config {}
  }

  depends_on = [google_storage_bucket.source]
}