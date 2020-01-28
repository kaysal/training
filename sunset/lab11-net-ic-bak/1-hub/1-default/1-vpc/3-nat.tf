
# cloud nat
#------------------------------------

# asia router

resource "google_compute_router" "router_asia" {
  name    = "router-asia"
  region  = var.hub.default.asia.region
  network = google_compute_network.default.self_link

  bgp {
    asn = var.hub.default.asn
  }
}

# asia nat

resource "google_compute_router_nat" "default_nat_asia" {
  name                               = "default-nat-asia"
  router                             = google_compute_router.router_asia.name
  region                             = var.hub.default.asia.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  min_ports_per_vm                   = "57344"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# eu router

resource "google_compute_router" "router_eu" {
  name    = "router-eu"
  region  = var.hub.default.eu.region
  network = google_compute_network.default.self_link

  bgp {
    asn = var.hub.default.asn
  }
}

# eu nat

resource "google_compute_router_nat" "default_nat_eu" {
  name                               = "default-nat-eu"
  router                             = google_compute_router.router_eu.name
  region                             = var.hub.default.eu.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  min_ports_per_vm                   = "57344"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

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
