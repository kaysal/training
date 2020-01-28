output "instance" {
  value = {
    spoke1_vm_a = google_compute_instance.spoke1_vm_a
    spoke1_vm_b = google_compute_instance.spoke1_vm_b
    spoke2_vm_a = google_compute_instance.spoke2_vm_a
    spoke2_vm_b = google_compute_instance.spoke2_vm_b
  }
}
