
provider "google" {}
provider "google-beta" {}

# gcp load balancer ip ranges
#---------------------------------------------
data "google_compute_lb_ip_ranges" "ranges" {}


# cloud
#---------------------------------------------

# vpc

resource "google_compute_network" "cloud_vpc" {
  project                 = var.project_id_cloud
  provider                = google-beta
  name                    = "${var.cloud.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "cloud_eu_subnet" {
  project       = var.project_id_cloud
  name          = "${var.cloud.prefix}eu-subnet"
  ip_cidr_range = var.cloud.eu.subnet
  region        = var.cloud.eu.region
  network       = google_compute_network.cloud_vpc.self_link
}

resource "google_compute_subnetwork" "cloud_asia_subnet" {
  project       = var.project_id_cloud
  name          = "${var.cloud.prefix}asia-subnet"
  ip_cidr_range = var.cloud.asia.subnet
  region        = var.cloud.asia.region
  network       = google_compute_network.cloud_vpc.self_link
}

resource "google_compute_subnetwork" "cloud_us_subnet" {
  project       = var.project_id_cloud
  name          = "${var.cloud.prefix}us-subnet"
  ip_cidr_range = var.cloud.us.subnet
  region        = var.cloud.us.region
  network       = google_compute_network.cloud_vpc.self_link
}

# firewall rules

resource "google_compute_firewall" "cloud_allow_ssh" {
  project = var.project_id_cloud
  name    = "${var.cloud.prefix}allow-ssh"
  network = google_compute_network.cloud_vpc.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloud_allow_rfc1918" {
  project  = var.project_id_cloud
  name     = "${var.cloud.prefix}allow-rfc1918"
  network  = google_compute_network.cloud_vpc.self_link
  priority = "500"

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "cloud_deny_http" {
  project  = var.project_id_cloud
  name     = "${var.cloud.prefix}deny-http"
  network  = google_compute_network.cloud_vpc.self_link
  priority = "100"

  deny {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0", ]
}
