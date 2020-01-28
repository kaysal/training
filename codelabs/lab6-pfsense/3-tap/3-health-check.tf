
# health check

resource "google_compute_health_check" "hc_collector" {
  name = "${var.trust.prefix}hc-http-80"

  http_health_check {
    port = 80
  }
}
