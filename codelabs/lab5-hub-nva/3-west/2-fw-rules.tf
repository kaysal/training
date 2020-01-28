
resource "google_compute_firewall" "west_allow_iap" {
  name    = "west-allow-iap"
  network = google_compute_network.west_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080"]
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "west_allow_rfc1918" {
  name    = "${var.west.prefix}allow-rfc1918"
  network = google_compute_network.west_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "west_allow_gfe" {
  name    = "west-allow-gfe"
  network = google_compute_network.west_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["80", "8080"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["web"]
}
