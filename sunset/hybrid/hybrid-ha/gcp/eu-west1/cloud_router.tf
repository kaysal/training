# Cloud routers
resource "google_compute_router" "eu_w1_cr1" {
  name    = "eu-w1-cr1"
  network = "${data.google_compute_network.vpc.self_link}"

  bgp {
    asn = 65000
  }
}

resource "google_compute_router" "eu_w1_cr2" {
  name    = "eu-w1-cr2"
  network = "${data.google_compute_network.vpc.self_link}"

  bgp {
    asn = 65000
  }
}

# gcp eu-w1-vpn-gw1
resource "google_compute_router_interface" "aws_eu_w1_vpc1_cgw1_tunnel1" {
  name       = "aws-eu-w1-vpc1-cgw1-tunnel1"
  router     = "${google_compute_router.eu_w1_cr1.name}"
  vpn_tunnel = "${google_compute_vpn_tunnel.to_aws_eu_w1_vpc1_cgw1_tunnel1.name}"
  ip_range = "${data.terraform_remote_state.aws_eu_west1_vpc1_data.gcp_eu_w1_vpc1_cgw1_tunnel1_cgw_inside_address}/30"
}

resource "google_compute_router_interface" "aws_eu_w1_vpc1_cgw1_tunnel2" {
  name       = "aws-eu-w1-vpc1-cgw1-tunnel2"
  router     = "${google_compute_router.eu_w1_cr1.name}"
  vpn_tunnel = "${google_compute_vpn_tunnel.to_aws_eu_w1_vpc1_cgw1_tunnel2.name}"
  ip_range = "${data.terraform_remote_state.aws_eu_west1_vpc1_data.gcp_eu_w1_vpc1_cgw1_tunnel2_cgw_inside_address}/30"
}

resource "google_compute_router_peer" "aws_eu_w1_vpc1_cgw1_tunnel1" {
  name                      = "aws-eu-w1-vpc1-cgw1-tunnel1"
  router                    = "${google_compute_router.eu_w1_cr1.name}"
  peer_ip_address           = "${data.terraform_remote_state.aws_eu_west1_vpc1_data.aws_eu_w1_vpc1_cgw1_tunnel1_vgw_inside_address}"
  peer_asn                  = 65010
  advertised_route_priority = 201
  interface                 = "${google_compute_router_interface.aws_eu_w1_vpc1_cgw1_tunnel1.name}"
}

resource "google_compute_router_peer" "aws_eu_w1_vpc1_cgw1_tunnel2" {
  name                      = "aws-eu-w1-vpc1-cgw1-tunnel2"
  router                    = "${google_compute_router.eu_w1_cr1.name}"
  peer_ip_address           = "${data.terraform_remote_state.aws_eu_west1_vpc1_data.aws_eu_w1_vpc1_cgw1_tunnel2_vgw_inside_address}"
  peer_asn                  = 65010
  advertised_route_priority = 251
  interface                 = "${google_compute_router_interface.aws_eu_w1_vpc1_cgw1_tunnel2.name}"
}

# gcp eu-w1-vpn-gw2
resource "google_compute_router_interface" "aws_eu_w1_vpc1_cgw2_tunnel1" {
  name       = "aws-eu-w1-vpc1-cgw2-tunnel1"
  router     = "${google_compute_router.eu_w1_cr2.name}"
  vpn_tunnel = "${google_compute_vpn_tunnel.to_aws_eu_w1_vpc1_cgw2_tunnel1.name}"
  ip_range = "${data.terraform_remote_state.aws_eu_west1_vpc1_data.gcp_eu_w1_vpc1_cgw2_tunnel1_cgw_inside_address}/30"
}

resource "google_compute_router_interface" "aws_eu_w1_vpc1_cgw2_tunnel2" {
  name       = "aws-eu-w1-vpc1-cgw2-tunnel2"
  router     = "${google_compute_router.eu_w1_cr2.name}"
  vpn_tunnel = "${google_compute_vpn_tunnel.to_aws_eu_w1_vpc1_cgw2_tunnel2.name}"
  ip_range = "${data.terraform_remote_state.aws_eu_west1_vpc1_data.gcp_eu_w1_vpc1_cgw2_tunnel2_cgw_inside_address}/30"
}

resource "google_compute_router_peer" "aws_eu_w1_vpc1_cgw2_tunnel1" {
  name                      = "aws-eu-w1-vpc1-cgw2-tunnel1"
  router                    = "${google_compute_router.eu_w1_cr2.name}"
  peer_ip_address           = "${data.terraform_remote_state.aws_eu_west1_vpc1_data.aws_eu_w1_vpc1_cgw2_tunnel1_vgw_inside_address}"
  peer_asn                  = 65010
  advertised_route_priority = 100
  interface                 = "${google_compute_router_interface.aws_eu_w1_vpc1_cgw2_tunnel1.name}"
}

resource "google_compute_router_peer" "aws_eu_w1_vpc1_cgw2_tunnel2" {
  name                      = "aws-eu-w1-vpc1-cgw2-tunnel2"
  router                    = "${google_compute_router.eu_w1_cr2.name}"
  peer_ip_address           = "${data.terraform_remote_state.aws_eu_west1_vpc1_data.aws_eu_w1_vpc1_cgw2_tunnel2_vgw_inside_address}"
  peer_asn                  = 65010
  advertised_route_priority = 151
  interface                 = "${google_compute_router_interface.aws_eu_w1_vpc1_cgw2_tunnel2.name}"
}
