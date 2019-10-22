
# health check

resource "google_compute_health_check" "hc_http_80" {
  project = var.project_id_vpc1
  name    = "${var.vpc1.prefix}hc-http-80"

  http_health_check {
    port = 80
  }
}
