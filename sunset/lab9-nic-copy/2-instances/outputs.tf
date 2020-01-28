output "instances" {
  value = {
    spoke1 = {
      vm1 = google_compute_instance.spoke1_vm1
      vm2 = google_compute_instance.spoke1_vm2
    }
    spoke2 = {
      vm1 = google_compute_instance.spoke2_vm1
      vm2 = google_compute_instance.spoke2_vm2
    }
  }
  sensitive = true
}
