# Create VPN Gateway
resource "aws_vpn_gateway" "us_e1_vpc1_vpgw" {
  vpc_id = "${aws_vpc.us_e1_vpc1.id}"
  amazon_side_asn = "${var.aws_side_asn}"

  tags {
    Name = "${var.name}-us-e1-vpc1-vpgw"
  }
}

# Create the remote customer gateway profiles
resource "aws_customer_gateway" "us_e1_vpc1_cgw1" {
  bgp_asn    = "${var.customer_side_asn}"
  ip_address = "${var.gcp_us_e1_vpn_gw1_ip}"
  type       = "ipsec.1"

  tags {
    Name = "${var.name}-us-e1-vpc1-cgw1"
  }
}

resource "aws_customer_gateway" "us_e1_vpc1_cgw2" {
  bgp_asn    = "${var.customer_side_asn}"
  ip_address = "${var.gcp_us_e1_vpn_gw2_ip}"
  type       = "ipsec.1"

  tags {
    Name = "${var.name}-us-e1-vpc1-cgw2"
  }
}

# Create the VPN tunnels to customer gateways
resource "aws_vpn_connection" "us_e1_vpc1_cgw1_to_gcp" {
  vpn_gateway_id        = "${aws_vpn_gateway.us_e1_vpc1_vpgw.id}"
  customer_gateway_id   = "${aws_customer_gateway.us_e1_vpc1_cgw1.id}"
  type                  = "ipsec.1"
  tunnel1_preshared_key = "${var.preshared_key}"
  tunnel2_preshared_key = "${var.preshared_key}"

  tags {
    Name = "${var.name}-us-e1-vpc1-cgw1-to-gcp"
  }
}

resource "aws_vpn_connection" "us_e1_vpc1_cgw2_to_gcp" {
  vpn_gateway_id        = "${aws_vpn_gateway.us_e1_vpc1_vpgw.id}"
  customer_gateway_id   = "${aws_customer_gateway.us_e1_vpc1_cgw2.id}"
  type                  = "ipsec.1"
  tunnel1_preshared_key = "${var.preshared_key}"
  tunnel2_preshared_key = "${var.preshared_key}"

  tags {
    Name = "${var.name}-us-e1-vpc1-cgw2-to-gcp"
  }
}
