
# payment processing
#-------------------------------------------

# us

resource "google_compute_instance_group" "payment_us" {
  name      = "payment-us"
  zone      = "${var.hub.default.us.region}-c"
  instances = [local.instances.payment_us.self_link]

  named_port {
    name = "http"
    port = 80
  }
}
