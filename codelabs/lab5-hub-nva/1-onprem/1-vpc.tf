
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
  ip_cidr_range = var.onprem.subnet
  region        = var.onprem.region
  network       = google_compute_network.onprem_vpc.self_link
}
