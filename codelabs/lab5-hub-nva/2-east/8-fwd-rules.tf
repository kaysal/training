
# east80

resource "google_compute_forwarding_rule" "fr_east80" {
  name                  = "${var.global.prefix}fr-east"
  region                = "europe-west1"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.east_be_svc_east80.self_link
  subnetwork            = google_compute_subnetwork.east_subnet.self_link
  ip_address            = "10.200.20.80"
  ip_protocol           = "TCP"
  all_ports             = "true"
}

# east8080

resource "google_compute_forwarding_rule" "fr_east8080" {
  name                  = "${var.global.prefix}fr-east8080"
  region                = "europe-west1"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.east_be_svc_east8080.self_link
  subnetwork            = google_compute_subnetwork.east_subnet.self_link
  ip_address            = "10.200.20.88"
  ip_protocol           = "TCP"
  all_ports             = "true"
}
