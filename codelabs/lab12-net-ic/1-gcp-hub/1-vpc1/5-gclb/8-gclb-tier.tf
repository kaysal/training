
# backend service

resource "google_compute_backend_service" "browse_tiers_be_svc" {
  provider        = google-beta
  name            = "browse-tiers-be-svc"
  port_name       = "http"
  protocol        = "HTTP"
  security_policy = google_compute_security_policy.allowed_clients.name

  backend {
    group           = "${local.zones}/${var.hub.vpc1.us.region}-c/instanceGroups/browse-us"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  health_checks = [local.vpc1_hc.self_link]

  depends_on = [
    google_compute_instance_group_manager.browse_us,
  ]
}

# url map

resource "google_compute_url_map" "standard_tier" {
  name            = "standard-tier-url-map"
  default_service = google_compute_backend_service.browse_tiers_be_svc.self_link
}

# http proxy

resource "google_compute_target_http_proxy" "http_proxy_standard_tier" {
  name    = "http-proxy-standard-tier"
  url_map = google_compute_url_map.standard_tier.self_link
}

# forwarding rule

resource "google_compute_forwarding_rule" "standard_tier_fr" {
  name         = "standard-tier-fr"
  target       = google_compute_target_http_proxy.http_proxy_standard_tier.self_link
  ip_address   = local.gclb_standard_vip.address
  network_tier = "STANDARD"
  region       = var.hub.vpc1.us.region
  ip_protocol  = "TCP"
  port_range   = "80"
}
