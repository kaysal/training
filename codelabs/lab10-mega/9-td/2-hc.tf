

resource "google_compute_health_check" "td_hc" {
  name = "td-hc"

  http_health_check {
    port_specification = "USE_SERVING_PORT"
  }

  check_interval_sec  = "5"
  timeout_sec         = "5"
  healthy_threshold   = "2"
  unhealthy_threshold = "2"
}
