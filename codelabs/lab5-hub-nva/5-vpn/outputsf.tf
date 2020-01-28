output "router" {
  value = {
    onprem = google_compute_router.onprem_router
    untrust = google_compute_router.untrust_router
  }
  sensitive = true
}
