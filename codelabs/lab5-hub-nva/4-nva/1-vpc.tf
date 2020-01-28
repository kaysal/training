
# untrust

resource "google_compute_network" "untrust_vpc" {
  provider                = google-beta
  name                    = "${var.untrust.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "untrust_subnet" {
  name                     = "${var.untrust.prefix}subnet"
  ip_cidr_range            = var.untrust.subnet
  region                   = var.untrust.region
  network                  = google_compute_network.untrust_vpc.self_link
  private_ip_google_access = true
}

# trust

resource "google_compute_network" "trust_vpc" {
  provider                = google-beta
  name                    = "${var.trust.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "trust_subnet" {
  name          = "${var.trust.prefix}subnet"
  ip_cidr_range = var.trust.subnet
  region        = var.trust.region
  network       = google_compute_network.trust_vpc.self_link
}

# mgt

resource "google_compute_network" "mgt_vpc" {
  provider                = google-beta
  name                    = "${var.mgt.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "mgt_subnet" {
  name          = "${var.mgt.prefix}subnet"
  ip_cidr_range = var.mgt.subnet
  region        = var.mgt.region
  network       = google_compute_network.mgt_vpc.self_link
}
