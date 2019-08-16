output "router" {
  value = {
    onprem = google_compute_router.onprem_router,
    cloud = google_compute_router.cloud_router
  }
}
