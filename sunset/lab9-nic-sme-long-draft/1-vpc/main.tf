
provider "google" {}
provider "google-beta" {}

# gcp load balancer ip ranges
#---------------------------------------------
data "google_compute_lb_ip_ranges" "ranges" {}

# hub
#---------------------------------------------

# vpc

resource "google_compute_network" "hub_vpc" {
  provider                = google-beta
  project                 = var.project_id_hub
  name                    = "${var.hub.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "hub_eu_subnet" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}eu-subnet"
  ip_cidr_range = var.hub.eu.subnet
  region        = var.hub.eu.region
  network       = google_compute_network.hub_vpc.self_link
}

resource "google_compute_subnetwork" "hub_asia_subnet" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}asia-subnet"
  ip_cidr_range = var.hub.asia.subnet
  region        = var.hub.asia.region
  network       = google_compute_network.hub_vpc.self_link
}

resource "google_compute_subnetwork" "hub_us_subnet" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}us-subnet"
  ip_cidr_range = var.hub.us.subnet
  region        = var.hub.us.region
  network       = google_compute_network.hub_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "hub_allow_ssh" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}allow-ssh"
  network = google_compute_network.hub_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_allow_rfc1918" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}allow-rfc1918"
  network = google_compute_network.hub_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.10.0.0/16",
    "10.1.0.0/16",
  ]
}
/*
resource "google_compute_firewall" "deny_http" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}deny-http"
  network = google_compute_network.hub_vpc.self_link

  deny {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}*/

# spoke1
#---------------------------------------------

# vpc

resource "google_compute_network" "spoke1_vpc" {
  project                 = var.project_id_spoke1
  provider                = google-beta
  name                    = "${var.spoke1.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "spoke1_eu_subnet" {
  project       = var.project_id_spoke1
  name          = "${var.spoke1.prefix}eu-subnet"
  ip_cidr_range = var.spoke1.eu.subnet
  region        = var.spoke1.eu.region
  network       = google_compute_network.spoke1_vpc.self_link
}

resource "google_compute_subnetwork" "spoke1_asia_subnet" {
  project       = var.project_id_spoke1
  name          = "${var.spoke1.prefix}asia-subnet"
  ip_cidr_range = var.spoke1.asia.subnet
  region        = var.spoke1.asia.region
  network       = google_compute_network.spoke1_vpc.self_link
}

resource "google_compute_subnetwork" "spoke1_us_subnet" {
  project       = var.project_id_spoke1
  name          = "${var.spoke1.prefix}us-subnet"
  ip_cidr_range = var.spoke1.us.subnet
  region        = var.spoke1.us.region
  network       = google_compute_network.spoke1_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "spoke1_allow_ssh" {
  project = var.project_id_spoke1
  name    = "${var.spoke1.prefix}allow-ssh"
  network = google_compute_network.spoke1_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "spoke1_allow_rfc1918" {
  project = var.project_id_spoke1
  name    = "${var.spoke1.prefix}allow-rfc1918"
  network = google_compute_network.spoke1_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "spoke1_gfe_http_ssl_tcp_internal" {
  provider    = google-beta
  project     = var.project_id_spoke1
  name        = "${var.spoke1.prefix}gfe-http-ssl-tcp-internal"
  description = "gfe http ssl tcp internal"
  network     = google_compute_network.spoke1_vpc.self_link

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = data.google_compute_lb_ip_ranges.ranges.http_ssl_tcp_internal
  target_tags   = [var.spoke1.hc_tag]
  #target_tags = ["some-tag"]
}

# spoke2
#---------------------------------------------

# vpc

resource "google_compute_network" "spoke2_vpc" {
  project                 = var.project_id_spoke2
  provider                = google-beta
  name                    = "${var.spoke2.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "spoke2_eu_subnet" {
  project       = var.project_id_spoke2
  name          = "${var.spoke2.prefix}eu-subnet"
  ip_cidr_range = var.spoke2.eu.subnet
  region        = var.spoke2.eu.region
  network       = google_compute_network.spoke2_vpc.self_link
}

resource "google_compute_subnetwork" "spoke2_asia_subnet" {
  project       = var.project_id_spoke2
  name          = "${var.spoke2.prefix}asia-subnet"
  ip_cidr_range = var.spoke2.asia.subnet
  region        = var.spoke2.asia.region
  network       = google_compute_network.spoke2_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "spoke2_allow_ssh" {
  project = var.project_id_spoke2
  name    = "${var.spoke2.prefix}allow-ssh"
  network = google_compute_network.spoke2_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "spoke2_allow_rfc1918" {
  project = var.project_id_spoke2
  name    = "${var.spoke2.prefix}allow-rfc1918"
  network = google_compute_network.spoke2_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "spoke2_gfe_http_ssl_tcp_internal" {
  provider    = google-beta
  project     = var.project_id_spoke2
  name        = "${var.spoke2.prefix}gfe-http-ssl-tcp-internal"
  description = "gfe http ssl tcp internal"
  network     = google_compute_network.spoke2_vpc.self_link

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = data.google_compute_lb_ip_ranges.ranges.http_ssl_tcp_internal
  target_tags   = [var.spoke2.hc_tag]
}

# cloud nat

resource "google_compute_router" "spoke2_asia_nat_router" {
  project = var.project_id_spoke2
  name    = "${var.spoke2.prefix}asia-nat-router"
  network = google_compute_network.spoke2_vpc.self_link
  region  = var.spoke2.asia.region
}

resource "google_compute_router_nat" "spoke2_nat" {
  project                = var.project_id_spoke2
  name                   = "${var.spoke2.prefix}asia-nat"
  router                 = google_compute_router.spoke2_asia_nat_router.name
  region                 = var.spoke2.asia.region
  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
