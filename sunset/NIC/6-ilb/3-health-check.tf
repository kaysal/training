
# health check

resource "google_compute_health_check" "hc_http_80" {
  project = var.project_id_spoke1
  name    = "${var.spoke2.prefix}hc-http-80"

  http_health_check {
    port = 80
  }
}
