
locals {
  zones = "https://www.googleapis.com/compute/v1/projects/hub-project-x/zones"
}

# browse

resource "google_compute_backend_service" "browse_be_svc" {
  provider  = google-beta
  name      = "browse-be-svc"
  port_name = "http"
  protocol  = "HTTP"
  #security_policy = google_compute_security_policy.allowed_clients.name

  backend {
    group           = "${local.zones}/${var.hub.default.asia.region}-b/instanceGroups/browse-asia"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.default.eu.region}-b/instanceGroups/browse-eu"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.default.us.region}-c/instanceGroups/browse-us"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.self_link]

  depends_on = [
    google_compute_instance_group_manager.browse_asia,
    google_compute_instance_group_manager.browse_eu,
    google_compute_instance_group_manager.browse_us,
  ]
}

resource "google_compute_backend_service" "browse_tiers_be_svc" {
  provider  = google-beta
  name      = "browse-tiers-be-svc"
  port_name = "http"
  protocol  = "HTTP"
  #security_policy = google_compute_security_policy.allowed_clients.name

  backend {
    group           = "${local.zones}/${var.hub.default.us.region}-c/instanceGroups/browse-us"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.self_link]

  depends_on = [
    google_compute_instance_group_manager.browse_us,
  ]
}

# cart

resource "google_compute_backend_service" "cart_be_svc" {
  provider  = google-beta
  name      = "cart-be-svc"
  port_name = "http"
  protocol  = "HTTP"
  #security_policy = google_compute_security_policy.allowed_clients.name

  backend {
    group           = "${local.zones}/${var.hub.default.asia.region}-b/instanceGroups/cart-asia"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.default.eu.region}-b/instanceGroups/cart-eu"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.default.us.region}-c/instanceGroups/cart-us"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.self_link]

  depends_on = [
    google_compute_instance_group_manager.cart_asia,
    google_compute_instance_group_manager.cart_eu,
    google_compute_instance_group_manager.cart_us,
  ]
}

# checkout

resource "google_compute_backend_service" "checkout_be_svc" {
  provider  = google-beta
  name      = "checkout-be-svc"
  port_name = "http"
  protocol  = "HTTP"
  #security_policy = google_compute_security_policy.allowed_clients.name

  backend {
    group           = "${local.zones}/${var.hub.default.asia.region}-b/instanceGroups/checkout-asia"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.default.eu.region}-b/instanceGroups/checkout-eu"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.default.us.region}-c/instanceGroups/checkout-us"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.self_link]

  depends_on = [
    google_compute_instance_group_manager.checkout_asia,
    google_compute_instance_group_manager.checkout_eu,
    google_compute_instance_group_manager.checkout_us,
  ]
}

# feeds

resource "google_compute_backend_service" "feeds_be_svc" {
  provider  = google-beta
  name      = "feeds-be-svc"
  port_name = "http"
  protocol  = "HTTP"
  #security_policy = google_compute_security_policy.allowed_clients.name

  backend {
    group           = "${local.zones}/${var.hub.default.asia.region}-b/instanceGroups/feeds-asia"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.default.eu.region}-b/instanceGroups/feeds-eu"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.default.us.region}-c/instanceGroups/feeds-us"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.self_link]

  depends_on = [
    google_compute_instance_group_manager.feeds_asia,
    google_compute_instance_group_manager.feeds_eu,
    google_compute_instance_group_manager.feeds_us,
  ]
}
