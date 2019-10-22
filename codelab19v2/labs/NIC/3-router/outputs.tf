output "routers" {
  value = {
    vpc1 = google_compute_router.vpc1_router_eu
    vpc2 = google_compute_router.vpc2_router
  }
  sensitive = true
}
