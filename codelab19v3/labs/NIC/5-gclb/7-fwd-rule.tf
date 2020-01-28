
# gclb global static ip address

resource "google_compute_global_address" "vip_gclb" {
  project     = var.project_id_vpc1
  name        = "${var.global.prefix}vip-gclb"
  description = "static ipv4 address for gclb frontend"
}

# forwarding rule

resource "google_compute_global_forwarding_rule" "fr_gclb" {
  provider    = google-beta
  project     = var.project_id_vpc1
  name        = "${var.vpc1.prefix}fr-gclb"
  target      = google_compute_target_http_proxy.http_proxy.self_link
  ip_address  = google_compute_global_address.vip_gclb.address
  ip_protocol = "TCP"
  port_range  = "80"
}
