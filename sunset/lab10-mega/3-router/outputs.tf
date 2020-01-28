output "routers" {
  value = {
    onprem = {
      eu   = google_compute_router.onprem_router_eu
      asia = google_compute_router.onprem_router_asia
      us   = google_compute_router.onprem_router_us
    }
    hub = {
      eu1   = google_compute_router.hub_router_eu1
      eu2   = google_compute_router.hub_router_eu2
      asia1 = google_compute_router.hub_router_asia1
      asia2 = google_compute_router.hub_router_asia2
      us1   = google_compute_router.hub_router_us1
      us2   = google_compute_router.hub_router_us2
    }
  }
  sensitive = true
}
