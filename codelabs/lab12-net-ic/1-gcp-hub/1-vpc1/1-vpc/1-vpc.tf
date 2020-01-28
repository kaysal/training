
# network
#------------------------------------

resource "google_compute_network" "vpc1" {
  name                    = "vpc1"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets
#------------------------------------

# asia

resource "google_compute_subnetwork" "browse_cidr_asia" {
  name          = "browse-cidr-asia"
  ip_cidr_range = var.hub.vpc1.asia.cidr.browse
  region        = var.hub.vpc1.asia.region
  network       = google_compute_network.vpc1.self_link

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.3
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "cart_cidr_asia" {
  name          = "cart-cidr-asia"
  ip_cidr_range = var.hub.vpc1.asia.cidr.cart
  region        = var.hub.vpc1.asia.region
  network       = google_compute_network.vpc1.self_link


}

resource "google_compute_subnetwork" "checkout_cidr_asia" {
  name          = "checkout-cidr-asia"
  ip_cidr_range = var.hub.vpc1.asia.cidr.checkout
  region        = var.hub.vpc1.asia.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "db_cidr_asia" {
  name          = "db-cidr-asia"
  ip_cidr_range = var.hub.vpc1.asia.cidr.db
  region        = var.hub.vpc1.asia.region
  network       = google_compute_network.vpc1.self_link
}

# eu

resource "google_compute_subnetwork" "browse_cidr_eu" {
  name          = "browse-cidr-eu"
  ip_cidr_range = var.hub.vpc1.eu.cidr.browse
  region        = var.hub.vpc1.eu.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "cart_cidr_eu" {
  name          = "cart-cidr-eu"
  ip_cidr_range = var.hub.vpc1.eu.cidr.cart
  region        = var.hub.vpc1.eu.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "checkout_cidr_eu" {
  name          = "checkout-cidr-eu"
  ip_cidr_range = var.hub.vpc1.eu.cidr.checkout
  region        = var.hub.vpc1.eu.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "db_cidr_eu" {
  name          = "db-cidr-eu"
  ip_cidr_range = var.hub.vpc1.eu.cidr.db
  region        = var.hub.vpc1.eu.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "batch_cidr_eu" {
  name          = "batch-cidr-eu"
  ip_cidr_range = var.hub.vpc1.eu.cidr.batch
  region        = var.hub.vpc1.eu.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "nic_cidr_eu" {
  name          = "nic-cidr-eu"
  ip_cidr_range = var.hub.vpc1.eu.cidr.nic
  region        = var.hub.vpc1.eu.region
  network       = google_compute_network.vpc1.self_link
}

# us

resource "google_compute_subnetwork" "browse_cidr_us" {
  name          = "browse-cidr-us"
  ip_cidr_range = var.hub.vpc1.us.cidr.browse
  region        = var.hub.vpc1.us.region
  network       = google_compute_network.vpc1.self_link

  log_config {
    aggregation_interval = "INTERVAL_1_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "cart_cidr_us" {
  name          = "cart-cidr-us"
  ip_cidr_range = var.hub.vpc1.us.cidr.cart
  region        = var.hub.vpc1.us.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "checkout_cidr_us" {
  name          = "checkout-cidr-us"
  ip_cidr_range = var.hub.vpc1.us.cidr.checkout
  region        = var.hub.vpc1.us.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "db_cidr_us" {
  name          = "db-cidr-us"
  ip_cidr_range = var.hub.vpc1.us.cidr.db
  region        = var.hub.vpc1.us.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "mqtt_cidr_us" {
  name          = "mqtt-cidr-us"
  ip_cidr_range = var.hub.vpc1.us.cidr.mqtt
  region        = var.hub.vpc1.us.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "nic_cidr_us" {
  name          = "nic-cidr-us"
  ip_cidr_range = var.hub.vpc1.us.cidr.nic
  region        = var.hub.vpc1.us.region
  network       = google_compute_network.vpc1.self_link
}

resource "google_compute_subnetwork" "probe_cidr_us" {
  name          = "probe-cidr-us"
  ip_cidr_range = var.hub.vpc1.us.cidr.probe
  region        = var.hub.vpc1.us.region
  network       = google_compute_network.vpc1.self_link

  log_config {
    aggregation_interval = "INTERVAL_5_MIN"
    flow_sampling        = 0.3
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_subnetwork" "payment_cidr_us" {
  name          = "payment-cidr-us"
  ip_cidr_range = var.hub.vpc1.us.cidr.payment
  region        = var.hub.vpc1.us.region
  network       = google_compute_network.vpc1.self_link
}
