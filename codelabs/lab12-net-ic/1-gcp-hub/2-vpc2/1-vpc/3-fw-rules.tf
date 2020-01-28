
# firewall rules
#------------------------------------

resource "google_compute_firewall" "vpc2_allow_iap" {
  name    = "vpc2-allow-iap"
  network = google_compute_network.vpc2.self_link

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "vpc2_allow_rfc1918" {
  name    = "vpc2-allow-rfc1918"
  network = google_compute_network.vpc2.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "vpc2_allow_gfe" {
  name    = "vpc2-allow-gfe"
  network = google_compute_network.vpc2.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "25", "80", "443"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["web"]
}
