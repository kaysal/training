
locals {
  eu_w1_neg = "k8s1-5b8fd3a7-default-td-url-host-80-0ceef91b"
  us_c1_neg = "k8s1-67c6905c-default-td-url-host-80-d588c3e3"
}

# eu west1

data "google_compute_network_endpoint_group" "neg_eu_w1_b" {
  name = local.eu_w1_neg
  zone = "europe-west1-b"
}

data "google_compute_network_endpoint_group" "neg_eu_w1_c" {
  name = local.eu_w1_neg
  zone = "europe-west1-c"
}

data "google_compute_network_endpoint_group" "neg_eu_w1_d" {
  name = local.eu_w1_neg
  zone = "europe-west1-d"
}

# us central1

data "google_compute_network_endpoint_group" "neg_us_c1_a" {
  name = local.us_c1_neg
  zone = "us-central1-a"
}

data "google_compute_network_endpoint_group" "neg_us_c1_c" {
  name = local.us_c1_neg
  zone = "us-central1-c"
}

data "google_compute_network_endpoint_group" "neg_us_c1_f" {
  name = local.us_c1_neg
  zone = "us-central1-f"
}

# backend service

resource "google_compute_backend_service" "be_svc" {
  provider    = google-beta
  name        = "be-svc"
  timeout_sec = "30"
  enable_cdn  = false

  # eu west1

  backend {
    group          = data.google_compute_network_endpoint_group.neg_eu_w1_b.self_link
    max_rate       = 5
    balancing_mode = "RATE"
  }

  backend {
    group          = data.google_compute_network_endpoint_group.neg_eu_w1_c.self_link
    max_rate       = 5
    balancing_mode = "RATE"
  }

  backend {
    group          = data.google_compute_network_endpoint_group.neg_eu_w1_d.self_link
    max_rate       = 5
    balancing_mode = "RATE"
  }

  # us central1

  backend {
    group          = data.google_compute_network_endpoint_group.neg_us_c1_a.self_link
    max_rate       = 5
    balancing_mode = "RATE"
  }

  backend {
    group          = data.google_compute_network_endpoint_group.neg_us_c1_c.self_link
    max_rate       = 5
    balancing_mode = "RATE"
  }

  backend {
    group          = data.google_compute_network_endpoint_group.neg_us_c1_f.self_link
    max_rate       = 5
    balancing_mode = "RATE"
  }

  load_balancing_scheme = "INTERNAL_SELF_MANAGED"
  health_checks         = ["${google_compute_health_check.td_hc.self_link}"]
}
