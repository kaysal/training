
resource "google_compute_health_check" "west_hc_west80" {
  name = "${var.global.prefix}west-hc-west80"

  http_health_check {
    port = 80
  }
}

resource "google_compute_health_check" "west_hc_west8080" {
  name = "${var.global.prefix}west-hc-west8080"

  http_health_check {
    port = 8080
  }
}
