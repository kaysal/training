
# vpc

resource "google_compute_network" "east_vpc" {
  provider                = google-beta
  name                    = "${var.east.prefix}vpc"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "east_subnet" {
  name          = "${var.east.prefix}subnet"
  ip_cidr_range = var.east.subnet
  region        = var.east.region
  network       = google_compute_network.east_vpc.self_link
}
