
# smtp

resource "google_compute_backend_service" "smtp_be_svc" {
  provider    = google-beta
  name        = "smtp-be-svc"
  port_name   = "http"
  protocol    = "TCP"
  timeout_sec = "30"

  backend {
    group           = google_compute_instance_group.smtp_us.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }

  health_checks = [local.default_hc.self_link]
}
