
# trust
#------------------------------------

# network

resource "google_compute_network" "vpc_trust" {
  name                    = "vpc-trust"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnet

resource "google_compute_subnetwork" "cidr_eu_trust" {
  name          = "cidr-eu-trust"
  ip_cidr_range = var.hub.vpc_trust.eu.cidr.natgw
  region        = var.hub.vpc_trust.eu.region
  network       = google_compute_network.vpc_trust.self_link
}


# untrust
#------------------------------------

# network

resource "google_compute_network" "vpc_untrust" {
  name                    = "vpc-untrust"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnet

resource "google_compute_subnetwork" "cidr_eu_untrust" {
  name          = "cidr-eu-untrust"
  ip_cidr_range = var.hub.vpc_untrust.eu.cidr.natgw
  region        = var.hub.vpc_untrust.eu.region
  network       = google_compute_network.vpc_untrust.self_link
}
