
# Internal forwarding rules.
# Separate FRs are created to allow us health check
# port 80 and 8080 separately...
# .. because the BE service can only health check a single port
# We can still chose to use ALL_PORTS instead os hard-coding ports
#---------------------------------

resource "google_compute_forwarding_rule" "nva_fr_east80" {
  provider              = google-beta
  name                  = "${var.global.prefix}nva-fr-east80"
  region                = "europe-west1"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.nva_be_svc_east80.self_link
  subnetwork            = google_compute_subnetwork.untrust_subnet.self_link
  ip_address            = "10.0.1.80"
  ip_protocol           = "TCP"
  ports                 = ["80"]
}

resource "google_compute_forwarding_rule" "nva_fr_east8080" {
  provider              = google-beta
  name                  = "${var.global.prefix}nva-fr-east8080"
  region                = "europe-west1"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.nva_be_svc_east8080.self_link
  subnetwork            = google_compute_subnetwork.untrust_subnet.self_link
  ip_address            = "10.0.1.88"
  ip_protocol           = "TCP"
  ports                 = ["8080"]
}
