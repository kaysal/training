output "routers" {
  value = {
    onprem = google_compute_router.onprem_router
    hub    = google_compute_router.hub_router
  }
  sensitive = true
}
