
# backend service
#---------------------------

# browse

resource "google_compute_backend_service" "browse_be_svc" {
  provider  = google-beta
  name      = "browse-be-svc"
  port_name = "http"
  protocol  = "HTTP"
  #enable_cdn = true
  security_policy = google_compute_security_policy.allowed_clients.name

  backend {
    group           = "${local.zones}/${var.hub.vpc1.asia.region}-b/instanceGroups/browse-asia"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.vpc1.eu.region}-b/instanceGroups/browse-eu"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.vpc1.us.region}-c/instanceGroups/browse-us"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  health_checks = [local.vpc1_hc.self_link]

  depends_on = [
    google_compute_instance_group_manager.browse_asia,
    google_compute_instance_group_manager.browse_eu,
    google_compute_instance_group_manager.browse_us,
  ]
}

# cart

resource "google_compute_backend_service" "cart_be_svc" {
  provider        = google-beta
  name            = "cart-be-svc"
  port_name       = "http"
  protocol        = "HTTP"
  security_policy = google_compute_security_policy.allowed_clients.name

  backend {
    group           = "${local.zones}/${var.hub.vpc1.asia.region}-b/instanceGroups/cart-asia"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.vpc1.eu.region}-b/instanceGroups/cart-eu"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.vpc1.us.region}-c/instanceGroups/cart-us"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  health_checks = [local.vpc1_hc.self_link]

  depends_on = [
    google_compute_instance_group_manager.cart_asia,
    google_compute_instance_group_manager.cart_eu,
    google_compute_instance_group_manager.cart_us,
  ]
}

# checkout

resource "google_compute_backend_service" "checkout_be_svc" {
  provider        = google-beta
  name            = "checkout-be-svc"
  port_name       = "http"
  protocol        = "HTTP"
  security_policy = google_compute_security_policy.allowed_clients.name

  backend {
    group           = "${local.zones}/${var.hub.vpc1.asia.region}-b/instanceGroups/checkout-asia"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.vpc1.eu.region}-b/instanceGroups/checkout-eu"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
  backend {
    group           = "${local.zones}/${var.hub.vpc1.us.region}-c/instanceGroups/checkout-us"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  health_checks = [local.vpc1_hc.self_link]

  depends_on = [
    google_compute_instance_group_manager.checkout_asia,
    google_compute_instance_group_manager.checkout_eu,
    google_compute_instance_group_manager.checkout_us,
  ]
}

# url map
#---------------------------

resource "google_compute_url_map" "shopping_site" {
  name            = "shopping-url-map"
  default_service = google_compute_backend_service.browse_be_svc.self_link

  host_rule {
    hosts        = [var.global.host]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_service.browse_be_svc.self_link

    path_rule {
      paths   = ["/browse/*", ]
      service = google_compute_backend_service.browse_be_svc.self_link
    }

    path_rule {
      paths   = ["/cart/*"]
      service = google_compute_backend_service.cart_be_svc.self_link
    }

    path_rule {
      paths   = ["/checkout/*", ]
      service = google_compute_backend_service.checkout_be_svc.self_link
    }
  }
}

# http proxy
#---------------------------

resource "google_compute_target_http_proxy" "http_proxy" {
  name    = "http-proxy"
  url_map = google_compute_url_map.shopping_site.self_link
}

# forwarding rule
#---------------------------

resource "google_compute_global_forwarding_rule" "shopping_site_fr" {
  name        = "shopping-site-fr"
  target      = google_compute_target_http_proxy.http_proxy.self_link
  ip_address  = local.gclb_vip.address
  ip_protocol = "TCP"
  port_range  = "80"
}
