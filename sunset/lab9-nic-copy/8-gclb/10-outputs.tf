output "addresses" {
  value = {
    spoke1 = {
      gclb = google_compute_global_address.vip_gclb
    }
  }
}
