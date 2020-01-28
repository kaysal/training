
# svc
#==============================================

# vpc: network

resource "google_compute_network" "svc_vpc" {
  provider                = google-beta
  project                 = var.project_id_svc
  name                    = "${var.svc.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# vpc: subnets

resource "google_compute_subnetwork" "svc_eu1_gke_cidr" {
  project       = var.project_id_svc
  name          = "svc-eu1-gke-cidr"
  region        = var.svc.eu1.region
  network       = google_compute_network.svc_vpc.self_link
  ip_cidr_range = "10.9.7.0/28"

  secondary_ip_range {
    range_name    = "svc-range"
    ip_cidr_range = "10.9.8.0/27"
  }

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.9.9.0/24"
  }
}

resource "google_compute_subnetwork" "svc_us1_gke_cidr" {
  project       = var.project_id_svc
  name          = "svc-us1-gke-cidr"
  region        = var.svc.us1.region
  network       = google_compute_network.svc_vpc.self_link
  ip_cidr_range = "10.9.7.16/28"

  secondary_ip_range {
    range_name    = "svc-range"
    ip_cidr_range = "10.9.8.32/27"
  }

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.9.10.0/24"
  }
}

resource "google_compute_subnetwork" "svc_eu1_cidr" {
  project       = var.project_id_svc
  name          = "${var.svc.prefix}eu1-cidr"
  ip_cidr_range = var.svc.eu1.cidr
  region        = var.svc.eu1.region
  network       = google_compute_network.svc_vpc.self_link
}

resource "google_compute_subnetwork" "svc_eu2_cidr" {
  project       = var.project_id_svc
  name          = "${var.svc.prefix}eu2-cidr"
  ip_cidr_range = var.svc.eu2.cidr
  region        = var.svc.eu2.region
  network       = google_compute_network.svc_vpc.self_link
}

resource "google_compute_subnetwork" "svc_asia1_cidr" {
  project       = var.project_id_svc
  name          = "${var.svc.prefix}asia1-cidr"
  ip_cidr_range = var.svc.asia1.cidr
  region        = var.svc.asia1.region
  network       = google_compute_network.svc_vpc.self_link
}

resource "google_compute_subnetwork" "svc_asia2_cidr" {
  project       = var.project_id_svc
  name          = "${var.svc.prefix}asia2-cidr"
  ip_cidr_range = var.svc.asia2.cidr
  region        = var.svc.asia2.region
  network       = google_compute_network.svc_vpc.self_link
}

resource "google_compute_subnetwork" "svc_us1_cidr" {
  project       = var.project_id_svc
  name          = "${var.svc.prefix}us1-cidr"
  ip_cidr_range = var.svc.us1.cidr
  region        = var.svc.us1.region
  network       = google_compute_network.svc_vpc.self_link
}

resource "google_compute_subnetwork" "svc_us2_cidr" {
  project       = var.project_id_svc
  name          = "${var.svc.prefix}us2-cidr"
  ip_cidr_range = var.svc.us2.cidr
  region        = var.svc.us2.region
  network       = google_compute_network.svc_vpc.self_link
}

# vpc: firewall rules

resource "google_compute_firewall" "svc_allow_ssh" {
  project = var.project_id_svc
  name    = "${var.svc.prefix}allow-ssh"
  network = google_compute_network.svc_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "svc_allow_rfc1918" {
  project = var.project_id_svc
  name    = "${var.svc.prefix}allow-rfc1918"
  network = google_compute_network.svc_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "svc_dns_egress_proxy" {
  project = var.project_id_svc
  name    = "${var.svc.prefix}dns-egress-proxy"
  network = google_compute_network.svc_vpc.self_link

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

resource "google_compute_firewall" "svc_gfe_http_ssl_tcp_internal" {
  project     = var.project_id_svc
  provider    = google-beta
  name        = "${var.svc.prefix}gfe-http-ssl-tcp-internal"
  description = "gfe http ssl tcp internal"
  network     = google_compute_network.svc_vpc.self_link

  allow {
    protocol = "tcp"
  }

  source_ranges = data.google_compute_lb_ip_ranges.ranges.http_ssl_tcp_internal
}

# vpc: cloud nat

## nat ips

resource "google_compute_address" "address_eu1" {
  project = var.project_id_svc
  count   = 2
  name    = "${var.svc.prefix}eu1-nat-ip${count.index}"
  region  = var.svc.eu1.region
}

resource "google_compute_address" "address_us1" {
  project = var.project_id_svc
  count   = 2
  name    = "${var.svc.prefix}us1-nat-ip${count.index}"
  region  = var.svc.us1.region
}

## routers

resource "google_compute_router" "router_nat_eu1" {
  project = var.project_id_svc
  name    = "${var.svc.prefix}router-nat-eu1"
  region  = var.svc.eu1.region
  network = google_compute_network.svc_vpc.self_link

  bgp {
    asn = var.svc.asn
  }
}

resource "google_compute_router" "router_nat_us1" {
  project = var.project_id_svc
  name    = "${var.svc.prefix}router-nat-us1"
  region  = var.svc.us1.region
  network = google_compute_network.svc_vpc.self_link

  bgp {
    asn = var.svc.asn
  }
}

## cloud nat

resource "google_compute_router_nat" "nat_eu1" {
  project                = var.project_id_svc
  name                   = "${var.svc.prefix}nat-eu1"
  router                 = google_compute_router.router_nat_eu1.name
  region                 = var.svc.eu1.region
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.address_eu1.*.self_link
  min_ports_per_vm       = "4096"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.svc_eu1_gke_cidr.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }

  log_config {
    enable = "true"
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router_nat" "nat_us1" {
  project                = var.project_id_svc
  name                   = "${var.svc.prefix}nat-us1"
  router                 = google_compute_router.router_nat_us1.name
  region                 = var.svc.us1.region
  nat_ip_allocate_option = "MANUAL_ONLY"
  nat_ips                = google_compute_address.address_us1.*.self_link
  min_ports_per_vm       = "4096"

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.svc_us1_gke_cidr.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }

  log_config {
    enable = "true"
    filter = "ERRORS_ONLY"
  }
}
