
# backend service on tcp/80

resource "google_compute_region_backend_service" "be_svc_collector" {
  name                  = "${var.trust.prefix}be-svc-collector"
  region                = var.trust.region
  protocol              = "TCP"
  session_affinity      = "CLIENT_IP"
  load_balancing_scheme = "INTERNAL"

  backend {
    group = google_compute_instance_group.instance_grp_pfsense.self_link
  }

  health_checks = [google_compute_health_check.hc_collector.self_link]
}
