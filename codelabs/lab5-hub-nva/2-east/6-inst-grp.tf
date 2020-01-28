
resource "google_compute_region_instance_group_manager" "east_mig" {
  name               = "${var.east.prefix}east-mig"
  base_instance_name = "${var.east.prefix}east-mig"
  region             = "europe-west1"

  version {
    instance_template = google_compute_instance_template.east_template.self_link
  }
}

# regional autoscalers

resource "google_compute_region_autoscaler" "east_autoscaler_mig" {
  name   = "${var.global.prefix}east-autoscaler-mig"
  region = "europe-west1"
  target = google_compute_region_instance_group_manager.east_mig.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 3
    cooldown_period = 45

    cpu_utilization {
      target = "0.5"
    }
  }
}
