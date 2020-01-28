
# onprem
#==============================================

# vpc: network

resource "google_compute_network" "onprem_vpc" {
  provider                = google-beta
  project                 = var.project_id_onprem
  name                    = "${var.onprem.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc: subnets

resource "google_compute_subnetwork" "onprem_eu_cidr" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}eu-cidr"
  ip_cidr_range = var.onprem.eu.cidr
  region        = var.onprem.eu.region
  network       = google_compute_network.onprem_vpc.self_link

  secondary_ip_range {
    range_name    = "dns-range"
    ip_cidr_range = var.onprem.eu.alias
  }
}

resource "google_compute_subnetwork" "onprem_asia_cidr" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}asia-cidr"
  ip_cidr_range = var.onprem.asia.cidr
  region        = var.onprem.asia.region
  network       = google_compute_network.onprem_vpc.self_link
}

resource "google_compute_subnetwork" "onprem_us_cidr" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}us-cidr"
  ip_cidr_range = var.onprem.us.cidr
  region        = var.onprem.us.region
  network       = google_compute_network.onprem_vpc.self_link
}

# vpc: firewall rules

resource "google_compute_firewall" "onprem_allow_ssh" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}allow-ssh"
  network = google_compute_network.onprem_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "onprem_allow_rfc1918" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}allow-rfc1918"
  network = google_compute_network.onprem_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "onprem_dns_egress_proxy" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}dns-egress-proxy"
  network = google_compute_network.onprem_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = ["35.199.192.0/19"]
}
