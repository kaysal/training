output "instances" {
  value = {
    vpc1 = {
      eu_vm   = google_compute_instance.vpc1_eu_vm
      asia_vm = google_compute_instance.vpc1_asia_vm
      us_vm   = google_compute_instance.vpc1_us_vm
    }
  }
  sensitive = true
}
