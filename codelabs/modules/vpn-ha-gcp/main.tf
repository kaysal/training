
resource "google_compute_vpn_tunnel" "tunnel" {
  provider         = "google-beta"
  count            = "${length(var.session_config)}"
  name             = "${lookup(var.session_config[count.index], "session_name")}-${count.index}"
  region           = "${var.region}"
  vpn_gateway      = "${var.vpn_gateway}"
  peer_gcp_gateway = "${var.peer_gcp_gateway}"
  shared_secret    = "${var.shared_secret}"
  router           = "${var.router}"

  vpn_gateway_interface = "${count.index}"
}

resource "google_compute_router_interface" "router_interface" {
  provider   = "google-beta"
  count      = "${length(var.session_config)}"
  name       = "${lookup(var.session_config[count.index], "session_name")}-${count.index}"
  router     = "${var.router}"
  region     = "${var.region}"
  ip_range   = "${lookup(var.session_config[count.index], "cr_bgp_session_range")}"
  vpn_tunnel =  "${google_compute_vpn_tunnel.tunnel[count.index].name}"
}

resource "google_compute_router_peer" "router_peer" {
  provider                  = "google-beta"
  count                     = "${length(var.session_config)}"
  name                      = "${lookup(var.session_config[count.index], "session_name")}-${count.index}"
  router                    = "${var.router}"
  region                    = "${var.region}"
  peer_ip_address           = "${lookup(var.session_config[count.index], "remote_bgp_session_ip")}"
  peer_asn                  = "${lookup(var.session_config[count.index], "peer_asn")}"
  advertised_route_priority = "${lookup(var.session_config[count.index], "advertised_route_priority")}"
  interface                 =  "${google_compute_router_interface.router_interface[count.index].name}"
}
