
# browse

resource "google_compute_backend_service" "browse_be_svc" {
  provider         = google-beta
  name             = "browse-be-svc"
  port_name        = "http"
  protocol         = "HTTP"
  session_affinity = "CLIENT_IP"
  #security_policy  = google_compute_security_policy.allow_external.name

  backend {
    group           = google_compute_instance_group.browse_asia.self_link
    balancing_mode  = "RATE"
    max_rate        = var.hub.default.asia.rps_med
    capacity_scaler = "1"
  }
  backend {
    group           = google_compute_instance_group.browse_eu.self_link
    balancing_mode  = "RATE"
    max_rate        = var.hub.default.eu.rps_med
    capacity_scaler = "1"
  }
  backend {
    group           = google_compute_instance_group.browse_us.self_link
    balancing_mode  = "RATE"
    max_rate        = var.hub.default.us.rps_med
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.default.self_link]
}

resource "google_compute_backend_service" "browse_tiers_be_svc" {
  provider         = google-beta
  name             = "browse-tiers-be-svc"
  port_name        = "http"
  protocol         = "HTTP"
  session_affinity = "CLIENT_IP"

  backend {
    group           = google_compute_instance_group.browse_us.self_link
    balancing_mode  = "RATE"
    max_rate        = var.hub.default.us.rps_med
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.default.self_link]
}

# cart

resource "google_compute_backend_service" "cart_be_svc" {
  provider         = google-beta
  name             = "cart-be-svc"
  port_name        = "http"
  protocol         = "HTTP"
  session_affinity = "CLIENT_IP"
  #security_policy  = google_compute_security_policy.allow_external.name

  backend {
    group           = google_compute_instance_group.cart_asia.self_link
    balancing_mode  = "RATE"
    max_rate        = var.hub.default.asia.rps_med
    capacity_scaler = "1"
  }
  backend {
    group           = google_compute_instance_group.cart_eu.self_link
    balancing_mode  = "RATE"
    max_rate        = var.hub.default.eu.rps_med
    capacity_scaler = "1"
  }
  backend {
    group           = google_compute_instance_group.cart_us.self_link
    balancing_mode  = "RATE"
    max_rate        = var.hub.default.us.rps_med
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.default.self_link]
}

# checkout

resource "google_compute_backend_service" "checkout_be_svc" {
  provider         = google-beta
  name             = "checkout-be-svc"
  port_name        = "http"
  protocol         = "HTTP"
  session_affinity = "CLIENT_IP"
  #security_policy  = google_compute_security_policy.allow_external.name

  backend {
    group           = google_compute_instance_group.checkout_asia.self_link
    balancing_mode  = "RATE"
    max_rate        = "${3 * var.hub.default.asia.rps_med}"
    capacity_scaler = "1"
  }
  backend {
    group           = google_compute_instance_group.checkout_eu.self_link
    balancing_mode  = "RATE"
    max_rate        = "${3 * var.hub.default.eu.rps_med}"
    capacity_scaler = "1"
  }
  backend {
    group           = google_compute_instance_group.checkout_us.self_link
    balancing_mode  = "RATE"
    max_rate        = "${3 * var.hub.default.us.rps_med}"
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.default.self_link]
}

# feeds

resource "google_compute_backend_service" "feeds_be_svc" {
  provider         = google-beta
  name             = "feeds-be-svc"
  port_name        = "http"
  protocol         = "HTTP"
  session_affinity = "CLIENT_IP"
  #security_policy  = google_compute_security_policy.allow_external.name

  backend {
    group           = google_compute_instance_group.feeds_asia.self_link
    balancing_mode  = "RATE"
    max_rate        = "${3 * var.hub.default.asia.rps_med}"
    capacity_scaler = "1"
  }
  backend {
    group           = google_compute_instance_group.feeds_eu.self_link
    balancing_mode  = "RATE"
    max_rate        = "${3 * var.hub.default.eu.rps_med}"
    capacity_scaler = "1"
  }
  backend {
    group           = google_compute_instance_group.feeds_us.self_link
    balancing_mode  = "RATE"
    max_rate        = "${3 * var.hub.default.us.rps_med}"
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.default.self_link]
}
