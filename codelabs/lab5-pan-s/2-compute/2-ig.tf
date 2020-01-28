
# ilb regional instance group

resource "google_compute_instance_group" "ig_b" {
  name      = "${var.global.prefix}ig-b"
  instances = [google_compute_instance.pan_b.self_link]
  zone      = "europe-west1-b"

  named_port {
    name = "http-80"
    port = "80"
  }

  named_port {
    name = "http-8080"
    port = "8080"
  }
}

resource "google_compute_instance_group" "ig_c" {
  name      = "${var.global.prefix}ig-c"
  instances = [google_compute_instance.pan_c.self_link]
  zone      = "europe-west1-c"

  named_port {
    name = "http-80"
    port = "80"
  }

  named_port {
    name = "http-8080"
    port = "8080"
  }
}

# health check

resource "google_compute_health_check" "hc_80" {
  name = "${var.global.prefix}hc-80"

  http_health_check {
    host         = "google-hc-80"
    port         = 80
    request_path = "/app80/"
  }
}

resource "google_compute_health_check" "hc_8080" {
  name = "${var.global.prefix}hc-8080"

  http_health_check {
    host         = "google-hc-8080"
    port         = 8080
    request_path = "/app8080/"
  }
}
