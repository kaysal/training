output "svc_account" {
  value     = google_service_account.gke_sa
  sensitive = true
}
