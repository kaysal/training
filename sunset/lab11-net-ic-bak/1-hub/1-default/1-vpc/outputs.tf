
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

output "smtp_tcp_proxy_vip" {
  value     = google_compute_global_address.smtp_tcp_proxy_vip
  sensitive = true
}

output "probe_eu_nat_ip" {
  value     = google_compute_address.probe_eu_nat_ip
  sensitive = true
}

output "probe_asia_nat_ip" {
  value     = google_compute_address.probe_asia_nat_ip
  sensitive = true
}

output "probe_us_nat_ip" {
  value     = google_compute_address.probe_us_nat_ip
  sensitive = true
}
