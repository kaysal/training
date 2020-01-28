
# firewall rules
#------------------------------------

resource "google_compute_firewall" "vpc1_allow_iap" {
  name    = "vpc1-allow-iap"
  network = google_compute_network.vpc1.self_link

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "vpc1_allow_rfc1918" {
  name    = "vpc1-allow-rfc1918"
  network = google_compute_network.vpc1.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "vpc1_allow_gfe" {
  name    = "vpc1-allow-gfe"
  network = google_compute_network.vpc1.self_link

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

# lockdown

resource "google_compute_firewall" "vpc1_egress_allow_rfc1918" {
  name      = "vpc1-egress-allow-rfc1918"
  network   = google_compute_network.vpc1.self_link
  direction = "EGRESS"
  priority  = "900"

  allow {
    protocol = "all"
  }

  destination_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]

  target_tags = ["lockdown"]
}

resource "google_compute_firewall" "vpc1_egress_deny_all" {
  name      = "vpc1-egress-deny-all"
  network   = google_compute_network.vpc1.self_link
  direction = "EGRESS"
  priority  = "1000"

  deny {
    protocol = "all"
  }

  target_tags = ["lockdown"]
}

# connectivity test
#---------------------------------

resource "google_compute_firewall" "vpc1_deny_http" {
  name    = "vpc1-deny-http"
  network = google_compute_network.vpc1.self_link

  deny {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12"
  ]

  target_tags = ["deny-http"]
}
