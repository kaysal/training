
# anthos
#------------------------------------

# network

resource "google_compute_network" "vpc_anthos" {
  name                    = "vpc-anthos"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnet

resource "google_compute_subnetwork" "cidr_eu_anthos" {
  name          = "cidr-eu-anthos"
  ip_cidr_range = var.hub.vpc_anthos.eu.cidr.anthos
  region        = var.hub.vpc_anthos.eu.region
  network       = google_compute_network.vpc_anthos.self_link
}
