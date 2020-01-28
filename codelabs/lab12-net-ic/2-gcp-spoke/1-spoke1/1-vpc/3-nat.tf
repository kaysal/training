
# cloud nat
#------------------------------------

# eu router

resource "google_compute_router" "spoke1_router_eu" {
  name    = "spoke1-router-eu"
  region  = var.spoke.vpc_spoke1.eu.region
  network = google_compute_network.vpc_spoke1.self_link

  bgp {
    asn = var.spoke.vpc_spoke1.asn
  }
}

# eu nat

resource "google_compute_router_nat" "spoke1_nat_eu" {
  name                               = "spoke1-nat-eu"
  router                             = google_compute_router.spoke1_router_eu.name
  region                             = var.spoke.vpc_spoke1.eu.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  min_ports_per_vm                   = "57344"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
