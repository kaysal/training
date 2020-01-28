
# east80

resource "google_compute_region_backend_service" "nva_be_svc_east80" {
  name             = "${var.global.prefix}nva-be-svc-east80"
  region           = "europe-west1"
  protocol         = "TCP"
  session_affinity = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.ig_b.self_link
  }

  backend {
    group = google_compute_instance_group.ig_c.self_link
  }

  health_checks = [google_compute_health_check.nva_hc_east80.self_link]
}

# east8080

resource "google_compute_region_backend_service" "nva_be_svc_east8080" {
  name             = "${var.global.prefix}nva-be-svc-east8080"
  region           = "europe-west1"
  protocol         = "TCP"
  session_affinity = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.ig_b.self_link
  }

  backend {
    group = google_compute_instance_group.ig_c.self_link
  }

  health_checks = [google_compute_health_check.nva_hc_east8080.self_link]
}
