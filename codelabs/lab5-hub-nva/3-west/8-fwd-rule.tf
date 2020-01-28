
# west80

resource "google_compute_forwarding_rule" "fr_west80" {
  name                  = "${var.global.prefix}fr-west"
  region                = "europe-west2"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.west_be_svc_west80.self_link
  subnetwork            = google_compute_subnetwork.west_subnet.self_link
  ip_address            = "10.200.20.80"
  ip_protocol           = "TCP"
  all_ports             = "true"
}

# west8080

resource "google_compute_forwarding_rule" "fr_west8080" {
  name                  = "${var.global.prefix}fr-west8080"
  region                = "europe-west2"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.west_be_svc_west8080.self_link
  subnetwork            = google_compute_subnetwork.west_subnet.self_link
  ip_address            = "10.200.20.88"
  ip_protocol           = "TCP"
  all_ports             = "true"
}
