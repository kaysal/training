
output "network" {
  value = {
    custom = google_compute_network.custom
    subnet = {
      custom_us = google_compute_subnetwork.custom_us
      custom_eu = google_compute_subnetwork.custom_eu
    }
  }
  sensitive = true
}
