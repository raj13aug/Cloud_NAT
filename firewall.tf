resource "google_compute_firewall" "allow-egress-via-nat" {
  name    = "allow-egress-via-nat"
  network = google_compute_network.vpc.name

  direction = "EGRESS"
  priority  = 1000

  destination_ranges = ["0.0.0.0/0"] # Allow outbound traffic to the internet
  allow {
    protocol = "tcp"
    ports    = ["80", "443"] # HTTP, HTTPS
  }
  allow {
    protocol = "udp"
    ports    = ["53"] # DNS Queries
  }

  target_tags = ["private-instance"]
}

resource "google_compute_firewall" "allow-return-traffic" {
  name    = "allow-return-traffic"
  network = google_compute_network.vpc.name

  direction = "INGRESS"
  priority  = 1000

  source_ranges = ["0.0.0.0/0"] # Allow responses from the internet
  allow {
    protocol = "all"
  }

  target_tags = ["private-instance"]
}