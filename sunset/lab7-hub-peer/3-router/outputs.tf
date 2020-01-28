output "routers" {
  value = {
    onprem_a = google_compute_router.onprem_router_a
    onprem_b = google_compute_router.onprem_router_b
    hub_a    = google_compute_router.hub_router_a
    hub_b    = google_compute_router.hub_router_b
  }
}
