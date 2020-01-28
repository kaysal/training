# Create VPC
#--------------------------------------
resource "google_compute_network" "vpc" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = "false"
}

# Create Subnets
#--------------------------------------
resource "google_compute_subnetwork" "eu_w1_subnet_10_10_10" {
  name          = "${var.name}-eu-w1-subnet-10-10-10"
  ip_cidr_range = "10.10.10.0/24"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "europe-west1"
}

resource "google_compute_subnetwork" "eu_w1_subnet_10_10_11" {
  name          = "${var.name}-eu-w1-subnet-10-10-11"
  ip_cidr_range = "10.10.11.0/24"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "europe-west1"
}

resource "google_compute_subnetwork" "us_e1_subnet_10_50_10" {
  name          = "${var.name}-us-e1-subnet-10-50-10"
  ip_cidr_range = "10.50.10.0/24"
  network       = "${google_compute_network.vpc.self_link}"
  region        = "us-east1"
}
