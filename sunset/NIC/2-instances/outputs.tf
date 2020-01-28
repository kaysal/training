output "instances" {
  value = {
    spoke1 = {
      vm_eu   = google_compute_instance.spoke1_vm_eu
      vm_asia = google_compute_instance.spoke1_vm_asia
      vm_us   = google_compute_instance.spoke1_vm_us
    }
    spoke2 = {
      vm_eu     = google_compute_instance.spoke2_vm_eu
      vm_asia_1 = google_compute_instance.spoke2_vm_asia_1
      vm_asia_2 = google_compute_instance.spoke2_vm_asia_2
    }
  }
  sensitive = true
}
