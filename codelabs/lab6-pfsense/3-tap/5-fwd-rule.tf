
# ilb internal static ip address

resource "google_compute_address" "vip_collector" {
  name         = "${var.global.prefix}vip-collector"
  region       = var.trust.region
  subnetwork   = local.trust.subnet1.self_link
  address      = var.trust.ilb_collector
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}
/*
# forwarding rule

resource "google_compute_forwarding_rule" "fr_ilb_collector" {
  provider              = google-beta
  name                  = "${var.trust.prefix}fr-ilb-collector"
  region                = var.trust.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.be_svc_collector.self_link
  subnetwork            = local.trust.subnet1.self_link
  ip_address            = var.trust.ilb_collector
  ip_protocol           = "TCP"
  all_ports             = true
}
*/
