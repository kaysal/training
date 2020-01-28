output "--- us-e1-vpc1-ubuntu ---" {
  value = [
    "az:        ${aws_instance.us_e1_vpc1_ubuntu.availability_zone } ",
    "priv ip:   ${aws_instance.us_e1_vpc1_ubuntu.private_ip} ",
    "pub ip:    ${aws_instance.us_e1_vpc1_ubuntu.public_ip} ",
    "priv dns:  ${aws_instance.us_e1_vpc1_ubuntu.private_dns} ",
    "key name:  ${aws_instance.us_e1_vpc1_ubuntu.key_name} ",
  ]
}

output "--- us-e1-vpc1-windows ---" {
  value = [
    "az:        ${aws_instance.us_e1_vpc1_windows.availability_zone } ",
    "priv ip:   ${aws_instance.us_e1_vpc1_windows.private_ip} ",
    "pub ip:    ${aws_instance.us_e1_vpc1_windows.public_ip} ",
    "priv dns:  ${aws_instance.us_e1_vpc1_windows.private_dns} ",
    "key name:  ${aws_instance.us_e1_vpc1_windows.key_name} ",
  ]
}

output "aws_us_e1_vpc1_cgw1_tunnel1_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw1_to_gcp.tunnel1_address}"
}

output "gcp_us_e1_vpc1_cgw1_tunnel1_cgw_inside_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw1_to_gcp.tunnel1_cgw_inside_address}"
}

output "aws_us_e1_vpc1_cgw1_tunnel1_vgw_inside_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw1_to_gcp.tunnel1_vgw_inside_address}"
}

output "aws_us_e1_vpc1_cgw1_tunnel2_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw1_to_gcp.tunnel2_address}"
}

output "gcp_us_e1_vpc1_cgw1_tunnel2_cgw_inside_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw1_to_gcp.tunnel2_cgw_inside_address}"
}

output "aws_us_e1_vpc1_cgw1_tunnel2_vgw_inside_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw1_to_gcp.tunnel2_vgw_inside_address}"
}

output "aws_us_e1_vpc1_cgw2_tunnel1_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw2_to_gcp.tunnel1_address}"
}

output "gcp_us_e1_vpc1_cgw2_tunnel1_cgw_inside_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw2_to_gcp.tunnel1_cgw_inside_address}"
}

output "aws_us_e1_vpc1_cgw2_tunnel1_vgw_inside_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw2_to_gcp.tunnel1_vgw_inside_address}"
}

output "aws_us_e1_vpc1_cgw2_tunnel2_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw2_to_gcp.tunnel2_address}"
}

output "gcp_us_e1_vpc1_cgw2_tunnel2_cgw_inside_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw2_to_gcp.tunnel2_cgw_inside_address}"
}

output "aws_us_e1_vpc1_cgw2_tunnel2_vgw_inside_address" {
  value = "${aws_vpn_connection.us_e1_vpc1_cgw2_to_gcp.tunnel2_vgw_inside_address}"
}
