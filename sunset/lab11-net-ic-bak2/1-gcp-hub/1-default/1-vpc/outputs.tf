
output "network" {
  value = {
    default = google_compute_network.default
  }
  sensitive = true
}

output "gclb_vip" {
  value     = google_compute_global_address.gclb_vip
  sensitive = true
}

output "gclb_vip_standard" {
  value     = google_compute_address.gclb_vip_standard
  sensitive = true
}

output "gclb_vip_premium" {
  value     = google_compute_global_address.gclb_vip_premium
  sensitive = true
}

output "mqtt_tcp_proxy_vip" {
  value     = google_compute_global_address.mqtt_tcp_proxy_vip
  sensitive = true
}

output "aws" {
  value = {
    tokyo_eip     = aws_eip.tokyo_eip
    london_eip    = aws_eip.london_eip
    ohio_eip      = aws_eip.ohio_eip
    singapore_eip = aws_eip.singapore_eip
  }
  sensitive = true
}
