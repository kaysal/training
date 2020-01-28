
# ilb internal static ip address

resource "google_compute_address" "vip_ilb" {
  name         = "${var.global.prefix}vip-ilb"
  region       = var.spoke2.region
  subnetwork   = local.spoke2.subnet1.self_link
  address      = var.spoke2.ilb_vip
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}

# forwarding rule

resource "google_compute_forwarding_rule" "fr_ilb" {
  provider              = google-beta
  name                  = "${var.spoke2.prefix}fr-ilb"
  region                = var.spoke2.region
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.be_svc_80.self_link
  subnetwork            = local.spoke2.subnet1.self_link
  ip_address            = var.spoke2.ilb_vip
  ip_protocol           = "TCP"
  ports                 = [80]
}
