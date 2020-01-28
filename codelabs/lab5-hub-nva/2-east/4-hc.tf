
resource "google_compute_health_check" "hc_80" {
  name = "${var.global.prefix}hc-80"

  http_health_check {
    port = 80
  }
}
/*
resource "google_compute_health_check" "east_hc_east8080" {
  name = "${var.global.prefix}east-hc-east8080"

  http_health_check {
    port = 8080
  }
}
*/
