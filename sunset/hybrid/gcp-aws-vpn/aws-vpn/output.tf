output "vpn_connection_tunnel1_address" {
  value = "${aws_vpn_connection.vpc-vpn.tunnel1_address}"
}

output "vpn_connection_tunnel2_address" {
  value = "${aws_vpn_connection.vpc-vpn.tunnel2_address}"
}
