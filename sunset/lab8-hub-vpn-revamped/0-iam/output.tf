output "iam" {
  value = {
    onprem = {
      svc_account = google_service_account.onprem_sa
    }
    hub = {
      svc_account = google_service_account.hub_sa
    }
    spoke1 = {
      svc_account = google_service_account.spoke1_sa
    }
    spoke2 = {
      svc_account = google_service_account.spoke2_sa
    }
  }
}
