
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# networks
#-----------------------------------------------

resource "google_compute_network" "custom" {
  project                 = var.project_id
  name                    = "custom"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "custom_asia" {
  project       = var.project_id
  name          = "custom-asia"
  ip_cidr_range = var.spoke.custom.asia.subnet
  region        = var.spoke.custom.asia.region
  network       = google_compute_network.custom.self_link
}

resource "google_compute_subnetwork" "custom_us" {
  project       = var.project_id
  name          = "custom-us"
  ip_cidr_range = var.spoke.custom.us.subnet
  region        = var.spoke.custom.us.region
  network       = google_compute_network.custom.self_link
}

resource "google_compute_subnetwork" "custom_eu" {
  project       = var.project_id
  name          = "custom-eu"
  ip_cidr_range = var.spoke.custom.eu.subnet
  region        = var.spoke.custom.eu.region
  network       = google_compute_network.custom.self_link
}

# firewall rules

resource "google_compute_firewall" "custom_allow_iap" {
  name    = "custom-allow-iap"
  network = google_compute_network.custom.self_link

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_firewall" "custom_allow_rfc1918" {
  name    = "custom-allow-rfc1918"
  network = google_compute_network.custom.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# cloud nat
#------------------------------------

# eu router

resource "google_compute_router" "custom_router_eu" {
  name    = "custom-router-eu"
  region  = var.spoke.custom.eu.region
  network = google_compute_network.custom.self_link

  bgp {
    asn = var.spoke.custom.asn
  }
}

# us router

resource "google_compute_router" "custom_router_us" {
  name    = "custom-router-us"
  region  = var.spoke.custom.us.region
  network = google_compute_network.custom.self_link

  bgp {
    asn = var.spoke.custom.asn
  }
}

# eu nat

resource "google_compute_router_nat" "custom_nat_eu" {
  name                               = "custom-nat-eu"
  router                             = google_compute_router.custom_router_eu.name
  region                             = var.spoke.custom.eu.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  min_ports_per_vm                   = "16384"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# us nat

resource "google_compute_router_nat" "custom_nat_us" {
  name                               = "custom-nat-us"
  router                             = google_compute_router.custom_router_us.name
  region                             = var.spoke.custom.us.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  min_ports_per_vm                   = "16384"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
