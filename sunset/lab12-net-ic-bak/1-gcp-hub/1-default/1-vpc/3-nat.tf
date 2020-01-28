
# cloud nat
#------------------------------------

# us router

resource "google_compute_router" "router_us" {
  name    = "router-us"
  region  = var.hub.default.us.region
  network = google_compute_network.default.self_link

  bgp {
    asn = var.hub.default.asn
  }
}

# us nat

resource "google_compute_router_nat" "default_nat_us" {
  name                               = "default-nat-us"
  router                             = google_compute_router.router_us.name
  region                             = var.hub.default.us.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  min_ports_per_vm                   = "57344"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
