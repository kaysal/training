
# network
#------------------------------------

resource "google_compute_network" "vpc2" {
  name                    = "vpc2"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets
#------------------------------------

# eu

resource "google_compute_subnetwork" "nic2_cidr_eu" {
  name          = "nic2-cidr-eu"
  ip_cidr_range = var.hub.vpc2.eu.cidr.nic
  region        = var.hub.vpc2.eu.region
  network       = google_compute_network.vpc2.self_link
}

# us

resource "google_compute_subnetwork" "data_cidr_us" {
  name          = "data-cidr-us"
  ip_cidr_range = var.hub.vpc2.us.cidr.data
  region        = var.hub.vpc2.us.region
  network       = google_compute_network.vpc2.self_link
}
