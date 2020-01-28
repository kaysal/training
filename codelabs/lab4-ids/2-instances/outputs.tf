
output "instances" {
  value = {
    vpc1 = {
      pfsense = google_compute_instance.pfsense
    }
  }
}
