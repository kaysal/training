output "instances" {
  value = {
    cloud = {
      eu_vm   = google_compute_instance.cloud_eu_vm
      asia_vm = google_compute_instance.cloud_asia_vm
      us_vm   = google_compute_instance.cloud_us_vm
    }
  }
  sensitive = true
}
