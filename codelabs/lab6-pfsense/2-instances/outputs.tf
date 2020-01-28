output "instances" {
  value = {
    trust = {
      pfsense = google_compute_instance.pfsense
      vm_solo = google_compute_instance.trust_vm_solo
    }
  }
  sensitive = true
}
