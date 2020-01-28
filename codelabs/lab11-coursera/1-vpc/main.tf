
# provider

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# data

data "google_compute_lb_ip_ranges" "ranges" {}

# network

resource "google_compute_network" "vpc" {
  provider                = google-beta
  name                    = "${var.orange.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "eu1_cidr" {
  name          = "${var.orange.prefix}eu1-cidr"
  region        = var.orange.eu1.region
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = var.orange.eu1.cidr.gce
}

resource "google_compute_subnetwork" "eu2_cidr" {
  name          = "${var.orange.prefix}eu2-cidr"
  region        = var.orange.eu2.region
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = var.orange.eu2.cidr.gce
}

resource "google_compute_subnetwork" "eu1_gke_cidr" {
  name          = "${var.orange.prefix}eu1-gke-cidr"
  region        = var.orange.eu1.region
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = var.orange.eu1.cidr.gke.node

  secondary_ip_range {
    range_name    = "svc-range"
    ip_cidr_range = var.orange.eu1.cidr.gke.svc
  }

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = var.orange.eu1.cidr.gke.pod
  }
}

resource "google_compute_subnetwork" "eu2_gke_cidr" {
  name          = "${var.orange.prefix}eu2-gke-cidr"
  region        = var.orange.eu2.region
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = var.orange.eu2.cidr.gke.node

  secondary_ip_range {
    range_name    = "svc-range"
    ip_cidr_range = var.orange.eu2.cidr.gke.svc
  }

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = var.orange.eu2.cidr.gke.pod
  }
}

# firewall rules

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.orange.prefix}allow-ssh"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_rfc1918" {
  name    = "${var.orange.prefix}allow-rfc1918"
  network = google_compute_network.vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "gfe_http_ssl_tcp_internal" {
  provider    = google-beta
  name        = "${var.orange.prefix}gfe-http-ssl-tcp-internal"
  description = "gfe http ssl tcp internal"
  network     = google_compute_network.vpc.self_link

  allow {
    protocol = "tcp"
  }

  source_ranges = data.google_compute_lb_ip_ranges.ranges.http_ssl_tcp_internal
}

# nat ips

resource "google_compute_address" "address_eu1" {
  count  = 2
  name   = "${var.orange.prefix}eu1-nat-ip${count.index}"
  region = var.orange.eu1.region
}

resource "google_compute_address" "address_eu2" {
  count  = 2
  name   = "${var.orange.prefix}eu2-nat-ip${count.index}"
  region = var.orange.eu2.region
}

# routers

resource "google_compute_router" "router_nat_eu1" {
  name    = "${var.orange.prefix}router-nat-eu1"
  region  = var.orange.eu1.region
  network = google_compute_network.vpc.self_link

  bgp {
    asn = var.orange.asn
  }
}

resource "google_compute_router" "router_nat_eu2" {
  name    = "${var.orange.prefix}router-nat-eu2"
  region  = var.orange.eu2.region
  network = google_compute_network.vpc.self_link

  bgp {
    asn = var.orange.asn
  }
}

## cloud nat

resource "google_compute_router_nat" "nat_eu1" {
  name                   = "${var.orange.prefix}nat-eu1"
  router                 = google_compute_router.router_nat_eu1.name
  region                 = var.orange.eu1.region
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.address_eu1.*.self_link
  min_ports_per_vm       = "4096"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.eu1_gke_cidr.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }

  log_config {
    enable = "true"
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router_nat" "nat_eu2" {
  name                   = "${var.orange.prefix}nat-eu2"
  router                 = google_compute_router.router_nat_eu2.name
  region                 = var.orange.eu2.region
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.address_eu2.*.self_link
  min_ports_per_vm       = "4096"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.eu2_gke_cidr.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }

  log_config {
    enable = "true"
    filter = "ERRORS_ONLY"
  }
}
