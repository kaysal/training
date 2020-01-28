
# onprem
#---------------------------------------------

# vpc

resource "google_compute_network" "onprem_vpc" {
  provider                = google-beta
  name                    = "${var.onprem.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "onprem_subnet" {
  name          = "${var.onprem.prefix}subnet"
  ip_cidr_range = var.onprem.subnet_cidr
  region        = var.onprem.region
  network       = google_compute_network.onprem_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "onprem_allow_ssh" {
  name    = "${var.onprem.prefix}allow-ssh"
  network = google_compute_network.onprem_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "onprem_allow_rfc1918" {
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

resource "google_compute_subnetwork" "untrust_subnet" {
  name                     = "${var.untrust.prefix}subnet"
  ip_cidr_range            = var.untrust.subnet_cidr
  region                   = var.untrust.region
  network                  = google_compute_network.untrust_vpc.self_link
  private_ip_google_access = true
}

# routes for restricted API IP range

resource "google_compute_route" "untrust_private_googleapis" {
  name             = "${var.untrust.prefix}private-googleapis"
  description      = "Route to default gateway for PGA"
  dest_range       = "199.36.153.4/30"
  network          = google_compute_network.untrust_vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

# firewall rules

resource "google_compute_firewall" "untrust_allow_ssh" {
  name    = "${var.untrust.prefix}allow-ssh"
  network = google_compute_network.untrust_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", 80, 8080]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "untrust_allow_rfc1918" {
  name    = "${var.untrust.prefix}allow-rfc1918"
  network = google_compute_network.untrust_vpc.self_link

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

resource "google_compute_subnetwork" "trust_subnet" {
  name          = "${var.trust.prefix}subnet"
  ip_cidr_range = var.trust.subnet_cidr
  region        = var.trust.region
  network       = google_compute_network.trust_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "trust_allow_ssh" {
  name    = "${var.trust.prefix}allow-ssh"
  network = google_compute_network.trust_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "trust_allow_rfc1918" {
  name    = "${var.trust.prefix}allow-rfc1918"
  network = google_compute_network.trust_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# mgt
#---------------------------------------------

# vpc

resource "google_compute_network" "mgt_vpc" {
  provider                = google-beta
  name                    = "${var.mgt.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "mgt_subnet" {
  name          = "${var.mgt.prefix}subnet"
  ip_cidr_range = var.mgt.subnet_cidr
  region        = var.mgt.region
  network       = google_compute_network.mgt_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "mgt_allow_ssh" {
  name    = "${var.mgt.prefix}allow-ssh"
  network = google_compute_network.mgt_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", 80, 443]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "mgt_allow_rfc1918" {
  name    = "${var.mgt.prefix}allow-rfc1918"
  network = google_compute_network.mgt_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# zone1
#---------------------------------------------

# vpc

resource "google_compute_network" "zone1_vpc" {
  provider                = google-beta
  name                    = "${var.zone1.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "zone1_subnet" {
  name          = "${var.zone1.prefix}subnet"
  ip_cidr_range = var.zone1.subnet_cidr
  region        = var.zone1.region
  network       = google_compute_network.zone1_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "zone1_allow_ssh" {
  name    = "${var.zone1.prefix}allow-ssh"
  network = google_compute_network.zone1_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22", 80, 8080]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "zone1_allow_rfc1918" {
  name    = "${var.zone1.prefix}allow-rfc1918"
  network = google_compute_network.zone1_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# network peering
