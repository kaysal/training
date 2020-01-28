
resource "google_compute_region_backend_service" "east_be_svc_east80" {
  name     = "${var.global.prefix}east-be-svc-east80"
  region   = "europe-west1"
  protocol = "TCP"

  backend {
    group = google_compute_region_instance_group_manager.east_mig.instance_group
  }

  health_checks = [google_compute_health_check.hc_80.self_link]
}

resource "google_compute_region_backend_service" "east_be_svc_east8080" {
  name     = "${var.global.prefix}east-be-svc-east8080"
  region   = "europe-west1"
  protocol = "TCP"

  backend {
    group = google_compute_region_instance_group_manager.east_mig.instance_group
  }

  health_checks = [google_compute_health_check.hc_80.self_link]
}
