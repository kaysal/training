
# backend service on tcp/80

resource "google_compute_region_backend_service" "be_svc_80" {
  name             = "${var.spoke2.prefix}be-svc-80"
  region           = var.spoke2.region
  protocol         = "TCP"
  session_affinity = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.instance_grp1.self_link
  }

  backend {
    group = google_compute_instance_group.instance_grp2.self_link
  }

  health_checks = [google_compute_health_check.hc_http_80.self_link]
}