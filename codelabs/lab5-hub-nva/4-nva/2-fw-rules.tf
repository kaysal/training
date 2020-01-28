
# untrust

resource "google_compute_firewall" "untrust_allow_external" {
  name    = "${var.untrust.prefix}allow-external"
  network = google_compute_network.untrust_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "untrust_allow_rfc1918" {
  name    = "${var.untrust.prefix}allow-rfc1918"
  network = google_compute_network.untrust_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# trust

resource "google_compute_firewall" "trust_allow_ssh" {
  name    = "${var.trust.prefix}allow-ssh"
  network = google_compute_network.trust_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "trust_allow_rfc1918" {
  name    = "${var.trust.prefix}allow-rfc1918"
  network = google_compute_network.trust_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# mgt

resource "google_compute_firewall" "mgt_allow_ssh" {
  name    = "${var.mgt.prefix}allow-ssh"
  network = google_compute_network.mgt_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "mgt_allow_rfc1918" {
  name    = "${var.mgt.prefix}allow-rfc1918"
  network = google_compute_network.mgt_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}
