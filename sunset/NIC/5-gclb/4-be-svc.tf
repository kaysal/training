
# backend service on tcp/80

resource "google_compute_backend_service" "be_svc_web" {
  project          = var.project_id_spoke1
  name             = "${var.spoke1.prefix}be-svc-web"
  port_name        = "http"
  protocol         = "HTTP"
  session_affinity = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.instance_grp_eu.self_link
  }
  backend {
    group = google_compute_instance_group.instance_grp_asia.self_link
  }
  backend {
    group = google_compute_instance_group.instance_grp_us.self_link
  }

  health_checks = [google_compute_health_check.hc_http_80.self_link]
}
