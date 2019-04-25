output "bind_nat_ip" {
  value = "${google_compute_instance.bind.network_interface.0.access_config.0.nat_ip}"
}
