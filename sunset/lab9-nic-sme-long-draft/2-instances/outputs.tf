output "instances" {
  value = {
    spoke1 = {
      eu_vm   = google_compute_instance.spoke1_eu_vm
      asia_vm = google_compute_instance.spoke1_asia_vm
      us_vm   = google_compute_instance.spoke1_us_vm
    }
    spoke2 = {
      eu_vm    = google_compute_instance.spoke2_eu_vm
      asia_vm1 = google_compute_instance.spoke2_asia_vm1
      asia_vm2 = google_compute_instance.spoke2_asia_vm2
    }
  }
  sensitive = true
}
