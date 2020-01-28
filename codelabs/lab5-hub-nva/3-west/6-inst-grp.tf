
resource "google_compute_region_instance_group_manager" "west_mig" {
  name               = "${var.west.prefix}west-mig"
  base_instance_name = "${var.west.prefix}west-mig"
  region             = "europe-west2"

  version {
    instance_template = google_compute_instance_template.west_template.self_link
  }
}

# regional autoscalers

resource "google_compute_region_autoscaler" "west_autoscaler_mig" {
  name   = "${var.global.prefix}west-autoscaler-mig"
  region = "europe-west2"
  target = google_compute_region_instance_group_manager.west_mig.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 3
    cooldown_period = 45

    cpu_utilization {
      target = "0.5"
    }
  }
}
