
locals {
  zones = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/zones"
}

# payment

resource "google_compute_region_backend_service" "payment_be_svc" {
  provider = google-beta
  name     = "payment-be-svc"
  region   = var.hub.default.us.region
  protocol = "TCP"

  backend {
    group = "${local.zones}/${var.hub.default.us.region}-c/instanceGroups/payment-us"
  }

  health_checks = [local.default_hc.self_link]
  depends_on    = [google_compute_instance_group_manager.payment_us]
}
