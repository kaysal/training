output "routers" {
  value = {
    hub    = google_compute_router.hub_router
    spoke1 = google_compute_router.spoke1_router_eu
  }
  sensitive = true
}
