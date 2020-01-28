
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# vpc1
#---------------------------------------------

# vpc

resource "google_compute_network" "vpc1" {
  provider                = google-beta
  name                    = "${var.vpc1.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "vpc1_subnet_collector" {
  name          = "${var.vpc1.prefix}collector"
  ip_cidr_range = var.vpc1.subnet_collector
  region        = var.vpc1.region
  network       = google_compute_network.vpc1.self_link
  #enable_flow_logs = true
}

resource "google_compute_subnetwork" "vpc1_subnet_mirror" {
  name          = "${var.vpc1.prefix}mirror"
  ip_cidr_range = var.vpc1.subnet_mirror
  region        = var.vpc1.region
  network       = google_compute_network.vpc1.self_link
  #enable_flow_logs = true
}

# firewall rules

resource "google_compute_firewall" "vpc1_allow_external" {
  provider = google-beta
  name     = "${var.vpc1.prefix}allow-external"
  network  = google_compute_network.vpc1.self_link
  #enable_logging = true

  allow {
    protocol = "tcp"
    ports    = ["22", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpc1_allow_rfc1918" {
  provider = google-beta
  name     = "${var.vpc1.prefix}allow-rfc1918"
  network  = google_compute_network.vpc1.self_link
  #enable_logging = true

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}


# vpc2
#---------------------------------------------

# vpc

resource "google_compute_network" "vpc2" {
  provider                = google-beta
  name                    = "${var.vpc2.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "vpc2_subnet_mirror" {
  name          = "${var.vpc2.prefix}subnet-mirror"
  ip_cidr_range = var.vpc2.subnet_mirror
  region        = var.vpc2.region
  network       = google_compute_network.vpc2.self_link
  #enable_flow_logs = true
}

# firewall rules

resource "google_compute_firewall" "vpc2_allow_ssh" {
  provider = google-beta
  name     = "${var.vpc2.prefix}allow-ssh"
  network  = google_compute_network.vpc2.self_link
  #enable_logging = true

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpc2_allow_rfc1918" {
  provider = google-beta
  name     = "${var.vpc2.prefix}allow-rfc1918"
  network  = google_compute_network.vpc2.self_link
  #enable_logging = true

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}
