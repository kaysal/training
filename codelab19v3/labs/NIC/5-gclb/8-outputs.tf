output "address" {
  value = {
    vpc1 = {
      gclb = google_compute_global_address.vip_gclb
    }
  }
  sensitive = true
}
