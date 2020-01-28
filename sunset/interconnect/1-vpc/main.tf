# provider

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# vpc

resource "google_compute_network" "vpc" {
  name                    = "${var.prefix}vpc"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.prefix}subnet"
  ip_cidr_range = "10.1.1.0/24"
  region        = "europe-west2"
  network       = google_compute_network.vpc.self_link
}
