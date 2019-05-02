output "cdn_ip" {
  value = "${google_compute_global_address.address.address}"
}
