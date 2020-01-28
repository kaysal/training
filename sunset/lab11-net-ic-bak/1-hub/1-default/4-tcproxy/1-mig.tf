
# smtp
#-------------------------------------------

# us

resource "google_compute_instance_group" "smtp_us" {
  name      = "smtp-us"
  zone      = "${var.hub.default.us.region}-c"
  instances = [local.instances.smtp_us.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}
