# https proxy frontend
resource "google_compute_target_tcp_proxy" "tcp_proxy_smtp" {
  name            = "tcp-proxy-smtp"
  backend_service = google_compute_backend_service.smtp_be_svc.self_link
}
