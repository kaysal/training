
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

resource "google_compute_firewall" "onprem_dns_egress_proxy" {
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

# cloud1
#---------------------------------------------

# vpc

resource "google_compute_network" "cloud1_vpc" {
  provider                = google-beta
  name                    = "${var.cloud1.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "cloud1_subnet" {
  name                     = "${var.cloud1.prefix}subnet"
  ip_cidr_range            = var.cloud1.subnet_cidr
  region                   = var.cloud1.region
  network                  = google_compute_network.cloud1_vpc.self_link
  private_ip_google_access = true
}

# routes for restricted API IP range

resource "google_compute_route" "cloud1_private_googleapis" {
  name             = "${var.cloud1.prefix}private-googleapis"
  description      = "Route to default gateway for PGA"
  dest_range       = "199.36.153.4/30"
  network          = google_compute_network.cloud1_vpc.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

# firewall rules

resource "google_compute_firewall" "cloud1_allow_ssh" {
  name    = "${var.cloud1.prefix}allow-ssh"
  network = google_compute_network.cloud1_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloud1_allow_rfc1918" {
  name    = "${var.cloud1.prefix}allow-rfc1918"
  network = google_compute_network.cloud1_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "cloud1_dns_egress_proxy" {
  name    = "${var.cloud1.prefix}dns-egress-proxy"
  network = google_compute_network.cloud1_vpc.self_link

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

# cloud2
#---------------------------------------------

# vpc

resource "google_compute_network" "cloud2_vpc" {
  provider                = google-beta
  name                    = "${var.cloud2.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "cloud2_subnet" {
  name          = "${var.cloud2.prefix}subnet"
  ip_cidr_range = var.cloud2.subnet_cidr
  region        = var.cloud2.region
  network       = google_compute_network.cloud2_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "cloud2_allow_ssh" {
  name    = "${var.cloud2.prefix}allow-ssh"
  network = google_compute_network.cloud2_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloud2_allow_rfc1918" {
  name    = "${var.cloud2.prefix}allow-rfc1918"
  network = google_compute_network.cloud2_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# cloud3
#---------------------------------------------

# vpc

resource "google_compute_network" "cloud3_vpc" {
  provider                = google-beta
  name                    = "${var.cloud3.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "cloud3_subnet" {
  name          = "${var.cloud3.prefix}subnet"
  ip_cidr_range = var.cloud3.subnet_cidr
  region        = var.cloud3.region
  network       = google_compute_network.cloud3_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "cloud3_allow_ssh" {
  name    = "${var.cloud3.prefix}allow-ssh"
  network = google_compute_network.cloud3_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloud3_allow_rfc1918" {
  name    = "${var.cloud3.prefix}allow-rfc1918"
  network = google_compute_network.cloud3_vpc.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}
