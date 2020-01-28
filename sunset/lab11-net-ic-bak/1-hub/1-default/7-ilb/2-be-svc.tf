
# payment

resource "google_compute_region_backend_service" "payment_be_svc" {
  provider = google-beta
  name     = "payment-be-svc"
  region   = var.hub.default.us.region
  protocol = "TCP"

  backend {
    group = google_compute_instance_group.payment_us.self_link
  }

  health_checks = [local.default_hc.self_link]
}
