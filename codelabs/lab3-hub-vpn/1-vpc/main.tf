
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# onprem
#---------------------------------------------

# vpc

resource "google_compute_network" "onprem_vpc" {
  provider                = google-beta
  name                    = "${var.onprem.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "onprem_subnet_a" {
  name          = "${var.onprem.prefix}subnet-a"
  ip_cidr_range = var.onprem.location_a_cidr
  region        = var.onprem.region_a
  network       = google_compute_network.onprem_vpc.self_link
}

resource "google_compute_subnetwork" "onprem_subnet_b" {
  name          = "${var.onprem.prefix}subnet-b"
  ip_cidr_range = var.onprem.location_b_cidr
  region        = var.onprem.region_b
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

# hub
#---------------------------------------------

# vpc

resource "google_compute_network" "hub_vpc" {
  provider                = google-beta
  name                    = "${var.hub.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# spoke1
#---------------------------------------------

# vpc

resource "google_compute_network" "spoke1_vpc" {
  provider                = google-beta
  name                    = "${var.spoke1.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "spoke1_subnet_a" {
  name          = "${var.spoke1.prefix}subnet-a"
  ip_cidr_range = var.spoke1.region_a_cidr
  region        = var.spoke1.region_a
  network       = google_compute_network.spoke1_vpc.self_link
}

resource "google_compute_subnetwork" "spoke1_subnet_b" {
  name          = "${var.spoke1.prefix}subnet-b"
  ip_cidr_range = var.spoke1.region_b_cidr
  region        = var.spoke1.region_b
  network       = google_compute_network.spoke1_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "spoke1_allow_ssh" {
  name    = "${var.spoke1.prefix}allow-ssh"
  network = google_compute_network.spoke1_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "spoke1_allow_rfc1918" {
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


# spoke2
#---------------------------------------------

# vpc

resource "google_compute_network" "spoke2_vpc" {
  provider                = google-beta
  name                    = "${var.spoke2.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "spoke2_subnet_a" {
  name          = "${var.spoke2.prefix}subnet-a"
  ip_cidr_range = var.spoke2.region_a_cidr
  region        = var.spoke2.region_a
  network       = google_compute_network.spoke2_vpc.self_link
}

resource "google_compute_subnetwork" "spoke2_subnet_b" {
  name          = "${var.spoke2.prefix}subnet-b"
  ip_cidr_range = var.spoke2.region_b_cidr
  region        = var.spoke2.region_b
  network       = google_compute_network.spoke2_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "spoke2_allow_ssh" {
  name    = "${var.spoke2.prefix}allow-ssh"
  network = google_compute_network.spoke2_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "spoke2_allow_rfc1918" {
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
