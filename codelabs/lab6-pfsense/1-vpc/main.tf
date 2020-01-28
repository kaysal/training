
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# untrust
#---------------------------------------------

# vpc

resource "google_compute_network" "untrust_vpc" {
  provider                = google-beta
  name                    = "${var.untrust.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "untrust_subnet1" {
  name             = "${var.untrust.prefix}subnet1"
  ip_cidr_range    = var.untrust.subnet1
  region           = var.untrust.region
  network          = google_compute_network.untrust_vpc.self_link
  enable_flow_logs = true
}

# firewall rules

resource "google_compute_firewall" "untrust_external" {
  provider       = google-beta
  name           = "${var.untrust.prefix}external"
  network        = google_compute_network.untrust_vpc.self_link
  enable_logging = true

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "8080"]
  }

  allow {
    protocol = "udp"
    ports    = ["500", "4500"]
  }

  allow {
    protocol = "esp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "untrust_allow_rfc1918" {
  provider       = google-beta
  name           = "${var.untrust.prefix}allow-rfc1918"
  network        = google_compute_network.untrust_vpc.self_link
  enable_logging = true

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
#---------------------------------------------

# vpc

resource "google_compute_network" "trust_vpc" {
  provider                = google-beta
  name                    = "${var.trust.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "trust_subnet1" {
  name                     = "${var.trust.prefix}subnet1"
  ip_cidr_range            = var.trust.subnet1
  region                   = var.trust.region
  network                  = google_compute_network.trust_vpc.self_link
  enable_flow_logs         = true
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "trust_subnet2" {
  name                     = "${var.trust.prefix}subnet2"
  ip_cidr_range            = var.trust.subnet2
  region                   = var.trust.region
  network                  = google_compute_network.trust_vpc.self_link
  enable_flow_logs         = true
  private_ip_google_access = true
}

# firewall rules

resource "google_compute_firewall" "trust_allow_all" {
  provider       = google-beta
  name           = "${var.trust.prefix}allow-all"
  network        = google_compute_network.trust_vpc.self_link
  enable_logging = true

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}
/*
resource "google_compute_firewall" "collector" {
  provider       = google-beta
  name           = "${var.trust.prefix}collector"
  network        = google_compute_network.trust_vpc.self_link
  enable_logging = true
  target_tags    = ["collector"]

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}*/
