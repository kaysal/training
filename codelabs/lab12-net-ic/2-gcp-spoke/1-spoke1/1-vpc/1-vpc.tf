
# networks
#-----------------------------------------------

resource "google_compute_network" "vpc_spoke1" {
  project                 = var.project_id
  name                    = "vpc-spoke1"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "data_eu" {
  project       = var.project_id
  name          = "data-eu"
  ip_cidr_range = var.spoke.vpc_spoke1.eu.cidr.ext_db
  region        = var.spoke.vpc_spoke1.eu.region
  network       = google_compute_network.vpc_spoke1.self_link
}
