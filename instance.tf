resource "google_storage_bucket" "source" {
  name          = "my-bucket-curl-cloud7"
  location      = "us-east1"
  force_destroy = true
}


resource "google_compute_instance" "test-instance" {
  name         = "test-instance"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = <<EOT
  set -xe \
    && sudo apt update gsutil curl -y \
    && curl -I https://www.google.com > ping.txt \
    && gsutil cp ping.txt gs://my-bucket-curl-cloud7/ \

EOT

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet-private.id
    access_config {}
  }

  depends_on = [google_storage_bucket.source]
}