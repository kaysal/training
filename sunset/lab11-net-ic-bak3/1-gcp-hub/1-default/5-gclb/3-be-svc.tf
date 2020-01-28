
locals {
  zones = "https://www.googleapis.com/compute/v1/projects/hub-project-x/zones"
}


/*
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
*/
