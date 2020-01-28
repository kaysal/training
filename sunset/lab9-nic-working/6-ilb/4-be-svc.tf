
# backend service on tcp/80

resource "google_compute_region_backend_service" "be_svc_web" {
  project               = var.project_id_spoke1
  name                  = "${var.spoke2.prefix}be-svc-web"
  region                = var.spoke2.asia.region
  protocol              = "TCP"
  session_affinity      = "CLIENT_IP"
  load_balancing_scheme = "INTERNAL"

  backend {
    group = google_compute_instance_group.asia_ig_b.self_link
  }
  backend {
    group = google_compute_instance_group.asia_ig_c.self_link
  }

  health_checks = [google_compute_health_check.hc_http_80.self_link]
}
