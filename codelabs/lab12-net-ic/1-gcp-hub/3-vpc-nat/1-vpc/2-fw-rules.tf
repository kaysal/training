
# trust
#------------------------------------

resource "google_compute_firewall" "vpc_trust_allow_iap" {
  name    = "vpc-trust-allow-iap"
  network = google_compute_network.vpc_trust.self_link

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "vpc_trust_allow_rfc1918" {
  name    = "vpc-trust-allow-rfc1918"
  network = google_compute_network.vpc_trust.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# untrust
#------------------------------------

resource "google_compute_firewall" "vpc_untrust_allow_iap" {
  name    = "vpc-untrust-allow-iap"
  network = google_compute_network.vpc_untrust.self_link

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "vpc_untrust_allow_rfc1918" {
  name    = "vpc-untrust-allow-rfc1918"
  network = google_compute_network.vpc_untrust.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}
