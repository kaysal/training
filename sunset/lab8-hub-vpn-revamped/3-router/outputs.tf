output "routers" {
  value = {
    onprem = {
      belgium_router = google_compute_router.onprem_belgium_router
      london_router  = google_compute_router.onprem_london_router
    }
    hub = {
      belgium_router = google_compute_router.hub_belgium_router
      london_router  = google_compute_router.hub_london_router
    }
  }
}
