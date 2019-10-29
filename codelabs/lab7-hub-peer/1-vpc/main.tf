
provider "google" {}

provider "google-beta" {}

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

resource "google_compute_subnetwork" "onprem_subnet_a" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}subnet-a"
  ip_cidr_range = var.onprem.location_a_cidr
  region        = var.onprem.region_a
  network       = google_compute_network.onprem_vpc.self_link
}

resource "google_compute_subnetwork" "onprem_subnet_b" {
  project       = var.project_id_onprem
  name          = "${var.onprem.prefix}subnet-b"
  ip_cidr_range = var.onprem.location_b_cidr
  region        = var.onprem.region_b
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
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "hub_subnet_a" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}subnet-a"
  ip_cidr_range = var.hub.region_a_cidr
  region        = var.hub.region_a
  network       = google_compute_network.hub_vpc.self_link
}

resource "google_compute_subnetwork" "hub_subnet_b" {
  project       = var.project_id_hub
  name          = "${var.hub.prefix}subnet-b"
  ip_cidr_range = var.hub.region_b_cidr
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

resource "google_compute_subnetwork" "spoke1_subnet_a" {
  project                  = var.project_id_spoke1
  name                     = "${var.spoke1.prefix}subnet-a"
  ip_cidr_range            = var.spoke1.region_a_cidr
  region                   = var.spoke1.region_a
  network                  = google_compute_network.spoke1_vpc.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "spoke1_subnet_b" {
  project                  = var.project_id_spoke1
  name                     = "${var.spoke1.prefix}subnet-b"
  ip_cidr_range            = var.spoke1.region_b_cidr
  region                   = var.spoke1.region_b
  network                  = google_compute_network.spoke1_vpc.self_link
  private_ip_google_access = true
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

resource "google_compute_subnetwork" "spoke2_subnet_a" {
  project                  = var.project_id_spoke2
  name                     = "${var.spoke2.prefix}subnet-a"
  ip_cidr_range            = var.spoke2.region_a_cidr
  region                   = var.spoke2.region_a
  network                  = google_compute_network.spoke2_vpc.self_link
  private_ip_google_access = true
}

resource "google_compute_subnetwork" "spoke2_subnet_b" {
  project                  = var.project_id_spoke2
  name                     = "${var.spoke2.prefix}subnet-b"
  ip_cidr_range            = var.spoke2.region_b_cidr
  region                   = var.spoke2.region_b
  network                  = google_compute_network.spoke2_vpc.self_link
  private_ip_google_access = true
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
