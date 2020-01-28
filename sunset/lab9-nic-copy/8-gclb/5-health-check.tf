
# health check

resource "google_compute_health_check" "hc_http_80" {
  name = "${var.spoke1.prefix}hc-http-80"

  http_health_check {
    port = 80
  }
}
