
resource "google_compute_region_backend_service" "west_be_svc_west80" {
  name     = "${var.global.prefix}west-be-svc-west80"
  region   = "europe-west2"
  protocol = "TCP"

  backend {
    group = google_compute_region_instance_group_manager.west_mig.instance_group
  }

  health_checks = [google_compute_health_check.west_hc_west80.self_link]
}

resource "google_compute_region_backend_service" "west_be_svc_west8080" {
  name     = "${var.global.prefix}west-be-svc-west8080"
  region   = "europe-west2"
  protocol = "TCP"

  backend {
    group = google_compute_region_instance_group_manager.west_mig.instance_group
  }

  health_checks = [google_compute_health_check.west_hc_west8080.self_link]
}
