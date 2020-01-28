
# cloud nat
#------------------------------------

# us router

resource "google_compute_router" "vpc2_router_us" {
  name    = "vpc2-router-us"
  region  = var.hub.vpc2.us.region
  network = google_compute_network.vpc2.self_link

  bgp {
    asn = var.hub.vpc2.asn
  }
}

# us nat

resource "google_compute_router_nat" "vpc2_nat_us" {
  name                               = "vpc2-nat-us"
  router                             = google_compute_router.vpc2_router_us.name
  region                             = var.hub.vpc2.us.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  min_ports_per_vm                   = "57344"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.data_cidr_us.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }

  log_config {
    enable = "true"
    filter = "ERRORS_ONLY"
  }
}
