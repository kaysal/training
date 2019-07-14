
output "self_link" {
  description = "The self_link of the Gateway"
  value       = "${var.vpn_gateway}"
}

output "vpn_tunnels_names" {
  description = "The VPN tunnel names"
  value       = "${google_compute_vpn_tunnel.tunnel.*.name}"
}

output "router_interface_names" {
  description = "The router interface names"
  value       = "${google_compute_router_interface.router_interface.*.name}"
}

output "ipsec_secret" {
  description = "The VPN pre-shared key"
  value       = "${google_compute_vpn_tunnel.tunnel.*.shared_secret}"
}
