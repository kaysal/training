
# payment processing
#-------------------------------------------

# us

resource "google_compute_instance_group_manager" "payment_us" {
  name               = "payment-us"
  base_instance_name = "payment-us"
  zone               = "${var.hub.vpc1.us.region}-c"

  version {
    instance_template = local.templates.payment_us.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.vpc1_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "payment_us" {
  name   = "payment-us"
  zone   = "${var.hub.vpc1.us.region}-c"
  target = google_compute_instance_group_manager.payment_us.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}
