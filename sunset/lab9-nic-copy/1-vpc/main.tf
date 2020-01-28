
provider "google" {}

provider "google-beta" {}

# gcp load balancer ip ranges
#---------------------------------------------
data "google_compute_lb_ip_ranges" "ranges" {}

# onprem
#---------------------------------------------

# vpc

resource "google_compute_network" "onprem_vpc" {
  provider                = google-beta
  project                 = var.project_id_onprem
  name                    = "${var.onprem.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "onprem_subnet1" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}subnet1"
  ip_cidr_range = var.onprem.subnet1
  region        = var.onprem.region
  network       = google_compute_network.onprem_vpc.self_link
}

resource "google_compute_subnetwork" "onprem_subnet2" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}subnet2"
  ip_cidr_range = var.onprem.subnet2
  region        = var.onprem.region
  network       = google_compute_network.onprem_vpc.self_link
}

resource "google_compute_subnetwork" "onprem_subnet3" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}subnet3"
  ip_cidr_range = var.onprem.subnet3
  region        = var.onprem.region
  network       = google_compute_network.onprem_vpc.self_link
}

# firewall rules

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

resource "google_compute_subnetwork" "hub_subnet1" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}subnet1"
  ip_cidr_range = var.hub.subnet1
  region        = var.hub.region_a
  network       = google_compute_network.hub_vpc.self_link
}

resource "google_compute_subnetwork" "hub_subnet2" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}subnet2"
  ip_cidr_range = var.hub.subnet2
  region        = var.hub.region_b
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
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "hub_dns_egress_proxy" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}dns-egress-proxy"
  network = google_compute_network.hub_vpc.self_link

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

# spoke1
#---------------------------------------------

# vpc

resource "google_compute_network" "spoke1_vpc" {
  project                 = var.project_id_spoke1
  provider                = google-beta
  name                    = "${var.spoke1.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "spoke1_subnet1" {
  project       = var.project_id_spoke1
  name          = "${var.spoke1.prefix}subnet1"
  ip_cidr_range = var.spoke1.subnet1
  region        = var.spoke1.region
  network       = google_compute_network.spoke1_vpc.self_link
}

resource "google_compute_subnetwork" "spoke1_subnet2" {
  project       = var.project_id_spoke1
  name          = "${var.spoke1.prefix}subnet2"
  ip_cidr_range = var.spoke1.subnet2
  region        = var.spoke1.region
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

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
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
  target_tags   = [var.spoke1.gclb_tag]
}

# routes

resource "google_compute_route" "spoke1_private_googleapis" {
  project          = var.project_id_spoke1
  name             = "${var.spoke1.prefix}private-googleapis"
  description      = "Route to default gateway for private.googleapis.com"
  dest_range       = "199.36.153.4/30"
  network          = google_compute_network.spoke1_vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

resource "google_compute_route" "spoke1_restricted_googleapis" {
  project          = var.project_id_spoke1
  name             = "${var.spoke1.prefix}restricted-googleapis"
  description      = "Route to default gateway for restricted.googleapis.com"
  dest_range       = "199.36.153.8/30"
  network          = google_compute_network.spoke1_vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

# cloud nat

resource "google_compute_router" "spoke1_nat_router" {
  project = var.project_id_spoke1
  name    = "${var.spoke1.prefix}nat-router"
  network = google_compute_network.spoke1_vpc.self_link
  region  = var.spoke1.region
}

resource "google_compute_router_nat" "spoke1_nat" {
  project                = var.project_id_spoke1
  name                   = "${var.spoke1.prefix}nat"
  router                 = google_compute_router.spoke1_nat_router.name
  region                 = var.spoke1.region
  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# spoke2
#---------------------------------------------

# vpc

resource "google_compute_network" "spoke2_vpc" {
  project                 = var.project_id_spoke2
  provider                = google-beta
  name                    = "${var.spoke2.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "spoke2_subnet1" {
  project       = var.project_id_spoke2
  name          = "${var.spoke2.prefix}subnet1"
  ip_cidr_range = var.spoke2.subnet1
  region        = var.spoke2.region
  network       = google_compute_network.spoke2_vpc.self_link
}

resource "google_compute_subnetwork" "spoke2_subnet2" {
  project       = var.project_id_spoke2
  name          = "${var.spoke2.prefix}subnet2"
  ip_cidr_range = var.spoke2.subnet2
  region        = var.spoke2.region
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

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
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
  target_tags   = [var.spoke2.ilb_tag]
}

# routes

resource "google_compute_route" "spoke2_private_googleapis" {
  project          = var.project_id_spoke2
  name             = "${var.spoke2.prefix}private-googleapis"
  description      = "Route to default gateway for private.googleapis.com"
  dest_range       = "199.36.153.4/30"
  network          = google_compute_network.spoke2_vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

resource "google_compute_route" "spoke2_restricted_googleapis" {
  project          = var.project_id_spoke2
  name             = "${var.spoke2.prefix}restricted-googleapis"
  description      = "Route to default gateway for restricted.googleapis.com"
  dest_range       = "199.36.153.8/30"
  network          = google_compute_network.spoke2_vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

# cloud nat

resource "google_compute_router" "spoke2_nat_router" {
  project = var.project_id_spoke2
  name    = "${var.spoke2.prefix}nat-router"
  network = google_compute_network.spoke2_vpc.self_link
  region  = var.spoke2.region
}

resource "google_compute_router_nat" "spoke2_nat" {
  project                = var.project_id_spoke2
  name                   = "${var.spoke1.prefix}nat"
  router                 = google_compute_router.spoke2_nat_router.name
  region                 = var.spoke2.region
  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
