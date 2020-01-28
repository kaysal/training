output "svc_account" {
  value = {
    onprem = google_service_account.onprem_sa
    hub    = google_service_account.hub_sa
    svc    = google_service_account.svc_sa
  }
  sensitive = true
}
