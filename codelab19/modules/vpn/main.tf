# VPN Gateways
resource "google_compute_vpn_gateway" "vpn_gateway" {
  name    = "${var.prefix}${var.gateway_name}"
  network = "${var.network}"
  region  = "${var.region}"
  project = "${var.project_id}"
}

# Assosciate external IP/Port-range to VPN-GW by using Forwarding rules
resource "google_compute_forwarding_rule" "vpn_esp" {
  name        = "${var.prefix}${var.gateway_name}-esp"
  ip_protocol = "ESP"
  ip_address  = "${var.gateway_ip}"
  target      = "${google_compute_vpn_gateway.vpn_gateway.self_link}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}

resource "google_compute_forwarding_rule" "vpn_udp500" {
  name        = "${var.prefix}${var.gateway_name}-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${var.gateway_ip}"
  target      = "${google_compute_vpn_gateway.vpn_gateway.self_link}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}

resource "google_compute_forwarding_rule" "vpn_udp4500" {
  name        = "${var.prefix}${var.gateway_name}-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${var.gateway_ip}"
  target      = "${google_compute_vpn_gateway.vpn_gateway.self_link}"
  project     = "${var.project_id}"
  region      = "${var.region}"
}

resource "google_compute_vpn_tunnel" "tunnel-dynamic" {
  count              = "${var.cr_name != "" ? var.tunnel_count : 0}"
  name               = "${var.prefix}${var.gateway_name}-tun${count.index+1}"
  region             = "${var.region}"
  project            = "${var.project_id}"
  peer_ip            = "${element(var.peer_ips, count.index)}"
  shared_secret      = "${var.shared_secret}"
  target_vpn_gateway = "${google_compute_vpn_gateway.vpn_gateway.self_link}"
  router             = "${var.cr_name}"
  ike_version        = "${var.ike_version}"

  depends_on = [
    "google_compute_forwarding_rule.vpn_esp",
    "google_compute_forwarding_rule.vpn_udp500",
    "google_compute_forwarding_rule.vpn_udp4500",
  ]
}

# For VPN gateways routing through BGP and Cloud Routers
## Create Router Interfaces
resource "google_compute_router_interface" "router_interface" {
  count      = "${var.cr_name != "" ? var.tunnel_count : 0}"
  name       = "${var.prefix}${var.gateway_name}-tun${count.index+1}"
  router     = "${var.cr_name}"
  region     = "${var.region}"
  ip_range   = "${element(var.bgp_cr_session_range, count.index)}"
  vpn_tunnel = "${google_compute_vpn_tunnel.tunnel-dynamic.*.name[count.index]}"
  project    = "${var.project_id}"

  depends_on = [
    "google_compute_vpn_tunnel.tunnel-dynamic",
  ]
}

## Create Peers
resource "google_compute_router_peer" "bgp_peer" {
  count                     = "${var.cr_name != "" ? var.tunnel_count : 0}"
  name                      = "${var.prefix}bgp-session-${count.index+1}"
  router                    = "${var.cr_name}"
  region                    = "${var.region}"
  peer_ip_address           = "${element(var.bgp_remote_session_range, count.index)}"
  peer_asn                  = "${element(var.peer_asn, count.index)}"
  advertised_route_priority = "${var.advertised_route_priority}"
  interface                 = "${var.prefix}${var.gateway_name}-tun${count.index+1}"
  project                   = "${var.project_id}"

  depends_on = [
    "google_compute_router_interface.router_interface",
  ]

  lifecycle {
    ignore_changes = ["ip_address"]
  }
}
