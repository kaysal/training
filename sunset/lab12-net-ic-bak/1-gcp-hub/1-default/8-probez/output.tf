
output "probe" {
  value = {
    us = google_compute_instance.probe_us
  }
  sensitive = true
}
