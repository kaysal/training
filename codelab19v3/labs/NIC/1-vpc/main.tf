
provider "google" {}
provider "google-beta" {}

# gcp load balancer ip ranges
#---------------------------------------------
data "google_compute_lb_ip_ranges" "ranges" {}


# vpc1
#---------------------------------------------

# vpc

resource "google_compute_network" "vpc1_vpc" {
  project                 = var.project_id_vpc1
  provider                = google-beta
  name                    = "${var.vpc1.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "vpc1_eu_subnet" {
  project       = var.project_id_vpc1
  name          = "${var.vpc1.prefix}eu-subnet"
  ip_cidr_range = var.vpc1.eu.subnet
  region        = var.vpc1.eu.region
  network       = google_compute_network.vpc1_vpc.self_link
}

resource "google_compute_subnetwork" "vpc1_asia_subnet" {
  project       = var.project_id_vpc1
  name          = "${var.vpc1.prefix}asia-subnet"
  ip_cidr_range = var.vpc1.asia.subnet
  region        = var.vpc1.asia.region
  network       = google_compute_network.vpc1_vpc.self_link
}

resource "google_compute_subnetwork" "vpc1_us_subnet" {
  project       = var.project_id_vpc1
  name          = "${var.vpc1.prefix}us-subnet"
  ip_cidr_range = var.vpc1.us.subnet
  region        = var.vpc1.us.region
  network       = google_compute_network.vpc1_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "vpc1_allow_ssh" {
  project = var.project_id_vpc1
  name    = "${var.vpc1.prefix}allow-ssh"
  network = google_compute_network.vpc1_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpc1_allow_rfc1918" {
  project = var.project_id_vpc1
  name    = "${var.vpc1.prefix}allow-rfc1918"
  network = google_compute_network.vpc1_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "vpc1_allow_health_checks" {
  provider    = google-beta
  project     = var.project_id_vpc1
  name        = "${var.vpc1.prefix}allow-health-checks"
  description = "gfe http ssl tcp internal"
  network     = google_compute_network.vpc1_vpc.self_link

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = data.google_compute_lb_ip_ranges.ranges.http_ssl_tcp_internal
  target_tags   = [var.vpc1.hc_tag]
  #target_tags = ["some-tag"]
}

# vpc2
#---------------------------------------------

# vpc

resource "google_compute_network" "vpc2_vpc" {
  provider                = google-beta
  project                 = var.project_id_vpc2
  name                    = "${var.vpc2.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "vpc2_eu_subnet" {
  project       = var.project_id_vpc2
  name          = "${var.vpc2.prefix}eu-subnet"
  ip_cidr_range = var.vpc2.eu.subnet
  region        = var.vpc2.eu.region
  network       = google_compute_network.vpc2_vpc.self_link
}

resource "google_compute_subnetwork" "vpc2_asia_subnet" {
  project       = var.project_id_vpc2
  name          = "${var.vpc2.prefix}asia-subnet"
  ip_cidr_range = var.vpc2.asia.subnet
  region        = var.vpc2.asia.region
  network       = google_compute_network.vpc2_vpc.self_link
}

resource "google_compute_subnetwork" "vpc2_us_subnet" {
  project       = var.project_id_vpc2
  name          = "${var.vpc2.prefix}us-subnet"
  ip_cidr_range = var.vpc2.us.subnet
  region        = var.vpc2.us.region
  network       = google_compute_network.vpc2_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "vpc2_allow_ssh" {
  project = var.project_id_vpc2
  name    = "${var.vpc2.prefix}allow-ssh"
  network = google_compute_network.vpc2_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpc2_allow_rfc1918" {
  project = var.project_id_vpc2
  name    = "${var.vpc2.prefix}allow-rfc1918"
  network = google_compute_network.vpc2_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["10.0.0.0/8"]
}

resource "google_compute_firewall" "deny_http" {
  project  = var.project_id_vpc2
  name     = "${var.vpc2.prefix}deny-http"
  network  = google_compute_network.vpc2_vpc.self_link
  disabled = true

  deny {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
}
