output "addresses" {
  value = {
    spoke2 = {
      ilb = google_compute_address.vip_ilb
    }
  }
}
