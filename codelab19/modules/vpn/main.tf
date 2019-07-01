resource "random_id" "ipsec_secret" {
  byte_length = 8
}

locals {
  default_shared_secret = var.shared_secret != "" ? var.shared_secret : random_id.ipsec_secret.b64_url
}

# static external ip for vpn gateway

resource "google_compute_address" "vpn_gw_ip" {
  count   = var.gateway_ip == null ? 1 : 0
  name    = "${var.gateway_name}-ip"
  region  = var.region
  project = var.project_id
}

# vpn gateway

resource "google_compute_vpn_gateway" "vpn_gateway" {
  name    = var.gateway_name
  network = var.network
  region  = var.region
  project = var.project_id
}

# assosciate external ip/port to vpn gateway

resource "google_compute_forwarding_rule" "vpn_esp" {
  name        = "${google_compute_vpn_gateway.vpn_gateway.name}-esp"
  ip_protocol = "ESP"
  ip_address  = var.gateway_ip != null ? var.gateway_ip : google_compute_address.vpn_gw_ip[0].address
  target      = google_compute_vpn_gateway.vpn_gateway.self_link
  project     = var.project_id
  region      = var.region
}

resource "google_compute_forwarding_rule" "vpn_udp500" {
  name        = "${google_compute_vpn_gateway.vpn_gateway.name}-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = var.gateway_ip != null ? var.gateway_ip : google_compute_address.vpn_gw_ip[0].address
  target      = google_compute_vpn_gateway.vpn_gateway.self_link
  project     = var.project_id
  region      = var.region
}

resource "google_compute_forwarding_rule" "vpn_udp4500" {
  name        = "${google_compute_vpn_gateway.vpn_gateway.name}-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = var.gateway_ip != null ? var.gateway_ip : google_compute_address.vpn_gw_ip[0].address
  target      = google_compute_vpn_gateway.vpn_gateway.self_link
  project     = var.project_id
  region      = var.region
}

# vpn tunnels

resource "google_compute_vpn_tunnel" "tunnel" {
  count         = "${length(var.peer_ips)}"
  name          = "${lookup(var.tunnel_config[count.index], "name")}"
  region        = var.region
  project       = var.project_id
  peer_ip       = "${element(var.peer_ips, count.index)}"
  shared_secret = local.default_shared_secret

  target_vpn_gateway = google_compute_vpn_gateway.vpn_gateway.self_link

  router      = var.cr_name
  ike_version = var.ike_version

  depends_on = [
    google_compute_forwarding_rule.vpn_esp,
    google_compute_forwarding_rule.vpn_udp500,
    google_compute_forwarding_rule.vpn_udp4500,
  ]
}

# cloud router interfaces

resource "google_compute_router_interface" "router_interface" {
  count      = "${length(var.peer_ips)}"
  region     = var.region
  router     = var.cr_name
  name       = "${lookup(var.tunnel_config[count.index], "name")}"
  ip_range   = "${lookup(var.tunnel_config[count.index], "cr_bgp_session_range")}"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel[count.index].name
  project    = var.project_id

  depends_on = [google_compute_vpn_tunnel.tunnel]
}

# bgp peers

resource "google_compute_router_peer" "bgp_peer" {
  count                     = "${length(var.peer_ips)}"
  project                   = var.project_id
  region                    = var.region
  router                    = var.cr_name
  name                      = "${lookup(var.tunnel_config[count.index], "name")}"
  peer_ip_address           = "${lookup(var.tunnel_config[count.index], "remote_bgp_session_ip")}"
  peer_asn                  = "${lookup(var.tunnel_config[count.index], "peer_asn")}"
  advertised_route_priority = "${lookup(var.tunnel_config[count.index], "advertised_route_priority")}"
  interface                 = "${lookup(var.tunnel_config[count.index], "name")}"

  depends_on = [google_compute_router_interface.router_interface]
}
