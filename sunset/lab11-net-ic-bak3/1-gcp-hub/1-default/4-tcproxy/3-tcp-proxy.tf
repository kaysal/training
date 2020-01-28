
# tcp proxy frontend

resource "google_compute_target_tcp_proxy" "tcp_proxy_mqtt" {
  name            = "tcp-proxy-mqtt"
  backend_service = google_compute_backend_service.mqtt_be_svc.self_link
}
