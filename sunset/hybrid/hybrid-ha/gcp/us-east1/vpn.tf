
# vpn configuration
# Attach the VPN gateways to the VPC.
resource "google_compute_vpn_gateway" "us_e1_vpn_gw1" {
  name    = "${var.name}-us-e1-vpn-gw1"
  network = "${data.google_compute_network.vpc.self_link}"
}

resource "google_compute_vpn_gateway" "us_e1_vpn_gw2" {
  name    = "${var.name}-us-e1-vpn-gw2"
  network = "${data.google_compute_network.vpc.self_link}"
}

# us-east1 vpn gw1
# --------------------------------------------
# Forwarding rules for ESP, UDP500 and UDP4500
resource "google_compute_forwarding_rule" "fr_esp_us_e1_vpn_gw1" {
  name        = "${var.name}-fr-esp-us-e1-vpn-gw1"
  ip_protocol = "ESP"
  ip_address  = "${data.google_compute_address.gcp_us_e1_vpn_gw1_ip.address}"
  target      = "${google_compute_vpn_gateway.us_e1_vpn_gw1.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp500_us_e1_vpn_gw1" {
  name        = "${var.name}-fr-udp500-us-e1-vpn-gw1"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${data.google_compute_address.gcp_us_e1_vpn_gw1_ip.address}"
  target      = "${google_compute_vpn_gateway.us_e1_vpn_gw1.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp4500_us_e1_vpn_gw1" {
  name        = "${var.name}-fr-udp4500-us-e1-vpn-gw1"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${data.google_compute_address.gcp_us_e1_vpn_gw1_ip.address}"
  target      = "${google_compute_vpn_gateway.us_e1_vpn_gw1.self_link}"
}

# vpn tunnels
resource "google_compute_vpn_tunnel" "to_aws_us_e1_vpc1_cgw1_tunnel1" {
  name               = "to-aws-us-e1-vpc1-cgw1-tunnel1"
  peer_ip            = "${data.terraform_remote_state.aws_us_east1_vpc1_data.aws_us_e1_vpc1_cgw1_tunnel1_address}"
  ike_version = "1"
  shared_secret      = "${var.preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.us_e1_vpn_gw1.self_link}"
  router = "${google_compute_router.us_e1_cr1.name}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp_us_e1_vpn_gw1",
    "google_compute_forwarding_rule.fr_udp500_us_e1_vpn_gw1",
    "google_compute_forwarding_rule.fr_udp4500_us_e1_vpn_gw1",
  ]
}

resource "google_compute_vpn_tunnel" "to_aws_us_e1_vpc1_cgw1_tunnel2" {
  name               = "to-aws-us-e1-vpc1-cgw1-tunnel2"
  peer_ip            = "${data.terraform_remote_state.aws_us_east1_vpc1_data.aws_us_e1_vpc1_cgw1_tunnel2_address}"
  ike_version = "1"
  shared_secret      = "${var.preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.us_e1_vpn_gw1.self_link}"
  router = "${google_compute_router.us_e1_cr1.name}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp_us_e1_vpn_gw1",
    "google_compute_forwarding_rule.fr_udp500_us_e1_vpn_gw1",
    "google_compute_forwarding_rule.fr_udp4500_us_e1_vpn_gw1",
  ]
}

# us-east1 vpn gw2
# --------------------------------------------
# Forwarding rules for ESP, UDP500 and UDP4500
resource "google_compute_forwarding_rule" "fr_esp_us_e1_vpn_gw2" {
  name        = "${var.name}-fr-esp-us-e1-vpn-gw2"
  ip_protocol = "ESP"
  ip_address  = "${data.google_compute_address.gcp_us_e1_vpn_gw2_ip.address}"
  target      = "${google_compute_vpn_gateway.us_e1_vpn_gw2.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp500_us_e1_vpn_gw2" {
  name        = "${var.name}-fr-udp500-us-e1-vpn-gw2"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${data.google_compute_address.gcp_us_e1_vpn_gw2_ip.address}"
  target      = "${google_compute_vpn_gateway.us_e1_vpn_gw2.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp4500_us_e1_vpn_gw2" {
  name        = "${var.name}-fr-udp4500-us-e1-vpn-gw2"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${data.google_compute_address.gcp_us_e1_vpn_gw2_ip.address}"
  target      = "${google_compute_vpn_gateway.us_e1_vpn_gw2.self_link}"
}

# us_e1_vpn_gw2
resource "google_compute_vpn_tunnel" "to_aws_us_e1_vpc1_cgw2_tunnel1" {
  name               = "to-aws-us-e1-vpc1-cgw2-tunnel1"
  peer_ip            = "${data.terraform_remote_state.aws_us_east1_vpc1_data.aws_us_e1_vpc1_cgw2_tunnel1_address}"
  ike_version = "1"
  shared_secret      = "${var.preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.us_e1_vpn_gw2.self_link}"
  router = "${google_compute_router.us_e1_cr2.name}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp_us_e1_vpn_gw2",
    "google_compute_forwarding_rule.fr_udp500_us_e1_vpn_gw2",
    "google_compute_forwarding_rule.fr_udp4500_us_e1_vpn_gw2",
  ]
}

resource "google_compute_vpn_tunnel" "to_aws_us_e1_vpc1_cgw2_tunnel2" {
  name               = "to-aws-us-e1-vpc1-cgw2-tunnel2"
  peer_ip            = "${data.terraform_remote_state.aws_us_east1_vpc1_data.aws_us_e1_vpc1_cgw2_tunnel2_address}"
  ike_version = "1"
  shared_secret      = "${var.preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.us_e1_vpn_gw2.self_link}"
  router = "${google_compute_router.us_e1_cr2.name}"

  depends_on = [
    "google_compute_forwarding_rule.fr_esp_us_e1_vpn_gw2",
    "google_compute_forwarding_rule.fr_udp500_us_e1_vpn_gw2",
    "google_compute_forwarding_rule.fr_udp4500_us_e1_vpn_gw2",
  ]
}
