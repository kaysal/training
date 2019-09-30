
# ilb internal static ip address

resource "google_compute_address" "vip_ilb" {
  project      = var.project_id_spoke1
  name         = "${var.global.prefix}vip-ilb"
  region       = var.spoke2.region_asia
  subnetwork   = local.spoke2.subnet_asia.self_link
  address      = var.spoke2.ilb_vip
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
}

# forwarding rule

resource "google_compute_forwarding_rule" "fr_ilb" {
  provider              = google-beta
  project               = var.project_id_spoke1
  name                  = "${var.spoke2.prefix}fr-ilb"
  region                = var.spoke2.region_asia
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.be_svc_web.self_link
  subnetwork            = local.spoke2.subnet_asia.self_link
  ip_address            = var.spoke2.ilb_vip
  ip_protocol           = "TCP"
  ports                 = [80]
}
