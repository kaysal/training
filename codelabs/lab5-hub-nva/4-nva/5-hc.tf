
# health check

resource "google_compute_health_check" "nva_hc_east80" {
  name = "${var.global.prefix}nva-hc-east80"

  http_health_check {
    port = 80
  }
}

resource "google_compute_health_check" "nva_hc_east8080" {
  name = "${var.global.prefix}nva-hc-east8080"

  http_health_check {
    port = 8080
  }
}
