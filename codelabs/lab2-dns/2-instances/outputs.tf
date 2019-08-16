output "instance" {
  value = {
    cloud1 = google_compute_instance.cloud1_vm
    cloud2 = google_compute_instance.cloud2_vm
    cloud3 = google_compute_instance.cloud3_vm
  }
}
