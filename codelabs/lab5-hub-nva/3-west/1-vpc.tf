
# vpc

resource "google_compute_network" "west_vpc" {
  provider                = google-beta
  name                    = "${var.west.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "west_subnet" {
  name          = "${var.west.prefix}subnet"
  ip_cidr_range = var.west.subnet
  region        = var.west.region
  network       = google_compute_network.west_vpc.self_link
}
