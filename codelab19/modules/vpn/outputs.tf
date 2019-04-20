output "project_id" {
  description = "The Project-ID"
  value       = "${google_compute_vpn_gateway.vpn_gateway.project}"
}

output "name" {
  description = "The name of the Gateway"
  value       = "${google_compute_vpn_gateway.vpn_gateway.name}"
}

output "network" {
  description = "The name of the VPC"
  value       = "${google_compute_vpn_gateway.vpn_gateway.network}"
}

output "vpn_tunnels_names-dynamic" {
  description = "The VPN tunnel name is"
  value       = "${google_compute_vpn_tunnel.tunnel-dynamic.*.name}"
}

output "ipsec_secret-dynamic" {
  description = "The secret"
  value       = "${google_compute_vpn_tunnel.tunnel-dynamic.*.shared_secret}"
}
