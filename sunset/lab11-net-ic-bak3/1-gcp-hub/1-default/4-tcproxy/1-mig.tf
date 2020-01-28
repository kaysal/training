
# mqtt
#-------------------------------------------

# us

resource "google_compute_instance_group_manager" "mqtt_us" {
  name               = "mqtt-us"
  base_instance_name = "mqtt-us"
  zone               = "${var.hub.default.us.region}-c"

  version {
    instance_template = local.templates.mqtt_us.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.default.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "mqtt_us" {
  name   = "mqtt-us"
  zone   = "${var.hub.default.us.region}-c"
  target = google_compute_instance_group_manager.mqtt_us.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}
