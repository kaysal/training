output "router" {
  value = {
    onprem = google_compute_router.onprem_router
    cloud1 = google_compute_router.cloud1_router
  }
}
