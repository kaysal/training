
# networks

resource "google_compute_network" "default" {
  name                    = "default"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = true
}

# firewall rules

resource "google_compute_firewall" "allow_gclb" {
  name    = "allow-gclb"
  network = google_compute_network.default.self_link

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

resource "google_compute_firewall" "allow_google_emea" {
  name    = "allow-google-emea"
  network = google_compute_network.default.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["104.132.162.95/32"]
}

resource "google_compute_firewall" "allow_google_netblocks" {
  name    = "allow-google-netblocks"
  network = google_compute_network.default.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "64.233.160.0/19",
    "66.102.0.0/20",
    "66.249.80.0/20",
    "72.14.192.0/18",
    "74.125.0.0/16",
    "108.177.8.0/21",
    "173.194.0.0/16",
    "209.85.128.0/17",
    "216.58.192.0/19",
    "216.239.32.0/19",
  ]
}

resource "google_compute_firewall" "allow_vpn" {
  name    = "allow-vpn"
  network = google_compute_network.default.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["10.250.0.0/24"]
}

resource "google_compute_firewall" "test_external_ip" {
  name    = "test-external-ip"
  network = google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "35.225.189.164/32",
    "35.241.186.171/32"
  ]

  target_tags = ["external-db"]
}

resource "google_compute_firewall" "default_allow_internal" {
  name    = "default-allow-internal"
  network = google_compute_network.default.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.128.0.0/9"]
}

resource "google_compute_firewall" "default_allow_peer" {
  name    = "default-allow-peer"
  network = google_compute_network.default.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["10.100.0.0/20"]
}
