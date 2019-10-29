output "svc_account" {
  value = {
    onprem = google_service_account.onprem_sa
    hub    = google_service_account.hub_sa
    spoke1 = google_service_account.spoke1_sa
    spoke2 = google_service_account.spoke2_sa
  }
}
