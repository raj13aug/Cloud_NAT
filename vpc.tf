resource "google_compute_network" "vpc" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet-public" {
  name                     = "my-public-subnet"
  region                   = "us-central1"
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = "10.0.0.0/24"
  private_ip_google_access = false
}

resource "google_compute_subnetwork" "subnet-private" {
  name                     = "my-private-subnet"
  region                   = "us-central1"
  network                  = google_compute_network.vpc.id
  ip_cidr_range            = "10.0.1.0/24"
  private_ip_google_access = true
}