
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

resource "google_compute_subnetwork" "hub_subnet_eu" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}subnet-eu"
  ip_cidr_range = var.hub.subnet_eu
  region        = var.hub.region_eu
  network       = google_compute_network.hub_vpc.self_link
}

resource "google_compute_subnetwork" "hub_subnet_asia" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}subnet-asia"
  ip_cidr_range = var.hub.subnet_asia
  region        = var.hub.region_asia
  network       = google_compute_network.hub_vpc.self_link
}

resource "google_compute_subnetwork" "hub_subnet_us" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}subnet-us"
  ip_cidr_range = var.hub.subnet_us
  region        = var.hub.region_us
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

resource "google_compute_subnetwork" "spoke1_subnet_eu" {
  project       = var.project_id_spoke1
  name          = "${var.spoke1.prefix}subnet-eu"
  ip_cidr_range = var.spoke1.subnet_eu
  region        = var.spoke1.region_eu
  network       = google_compute_network.spoke1_vpc.self_link
}

resource "google_compute_subnetwork" "spoke1_subnet_asia" {
  project       = var.project_id_spoke1
  name          = "${var.spoke1.prefix}subnet-asia"
  ip_cidr_range = var.spoke1.subnet_asia
  region        = var.spoke1.region_asia
  network       = google_compute_network.spoke1_vpc.self_link
}

resource "google_compute_subnetwork" "spoke1_subnet_us" {
  project       = var.project_id_spoke1
  name          = "${var.spoke1.prefix}subnet-us"
  ip_cidr_range = var.spoke1.subnet_us
  region        = var.spoke1.region_us
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
  target_tags   = [var.spoke1.gclb_tag]
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

resource "google_compute_subnetwork" "spoke2_subnet_eu" {
  project       = var.project_id_spoke2
  name          = "${var.spoke2.prefix}subnet-eu"
  ip_cidr_range = var.spoke2.subnet_eu
  region        = var.spoke2.region_eu
  network       = google_compute_network.spoke2_vpc.self_link
}

resource "google_compute_subnetwork" "spoke2_subnet_asia" {
  project       = var.project_id_spoke2
  name          = "${var.spoke2.prefix}subnet-asia"
  ip_cidr_range = var.spoke2.subnet_asia
  region        = var.spoke2.region_asia
  network       = google_compute_network.spoke2_vpc.self_link
}

resource "google_compute_subnetwork" "spoke2_subnet_us" {
  project       = var.project_id_spoke2
  name          = "${var.spoke2.prefix}subnet-us"
  ip_cidr_range = var.spoke2.subnet_us
  region        = var.spoke2.region_us
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
  target_tags   = [var.spoke2.ilb_tag]
}

# cloud nat

resource "google_compute_router" "spoke2_nat_router_asia" {
  project = var.project_id_spoke2
  name    = "${var.spoke2.prefix}nat-router-asia"
  network = google_compute_network.spoke2_vpc.self_link
  region  = var.spoke2.region_asia
}

resource "google_compute_router_nat" "spoke2_nat" {
  project                = var.project_id_spoke2
  name                   = "${var.spoke1.prefix}nat-asia"
  router                 = google_compute_router.spoke2_nat_router_asia.name
  region                 = var.spoke2.region_asia
  nat_ip_allocate_option = "AUTO_ONLY"

  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
