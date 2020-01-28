
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# networks
#-----------------------------------------------

resource "google_compute_network" "custom" {
  project                 = var.project_id
  name                    = "custom-vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "custom_us" {
  project       = var.project_id
  name          = "custom-us"
  ip_cidr_range = var.hub.custom.us.subnet
  region        = var.hub.custom.us.region
  network       = google_compute_network.custom.self_link
}

resource "google_compute_subnetwork" "custom_eu" {
  project       = var.project_id
  name          = "custom-eu"
  ip_cidr_range = var.hub.custom.eu.subnet
  region        = var.hub.custom.eu.region
  network       = google_compute_network.custom.self_link
}

# firewall rules

resource "google_compute_firewall" "custom_allow_iap" {
  name    = "custom-allow-iap"
  network = google_compute_network.custom.self_link

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "custom_allow_rfc1918" {
  name    = "custom-allow-rfc1918"
  network = google_compute_network.custom.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# lockdown

resource "google_compute_firewall" "custom_egress_allow_rfc1918" {
  name      = "custom-egress-allow-rfc1918"
  network   = google_compute_network.custom.self_link
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

resource "google_compute_firewall" "custom_egress_deny_all" {
  name      = "custom-egress-deny-all"
  network   = google_compute_network.custom.self_link
  direction = "EGRESS"
  priority  = "1000"

  deny {
    protocol = "all"
  }

  target_tags = ["lockdown"]
}
