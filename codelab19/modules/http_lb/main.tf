# instance template

resource "google_compute_instance_template" "instance_template" {
  project      = "${var.project_id}"
  name         = "${var.prefix}${var.instance_template_name}"
  region       = "${var.region}"
  machine_type = "${var.machine_type}"
  tags         = "${var.tags}"

  disk {
    source_image = "${var.image}"
    boot         = true
  }

  network_interface {
    subnetwork_project = "${var.subnetwork_project}"
    subnetwork         = "${var.subnetwork}"
    access_config      = {}
  }

  metadata_startup_script = "${var.metadata_startup_script}"

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# managed instance group

resource "google_compute_region_instance_group_manager" "mig" {
  project            = "${var.project_id}"
  name               = "${var.instance_group_name}"
  base_instance_name = "${var.instance_group_name}"
  instance_template  = "${google_compute_instance_template.instance_template.self_link}"
  region             = "${var.region}"
  target_size        = 1

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_region_autoscaler" "autoscaler" {
  project = "${var.project_id}"
  name    = "autoscaler"
  region  = "${var.region}"
  target  = "${google_compute_region_instance_group_manager.mig.self_link}"

  autoscaling_policy = {
    max_replicas    = "${var.autoscaler_max_replicas}"
    min_replicas    = "${var.autoscaler_min_replicas}"
    cooldown_period = "${var.autoscaler_cooldown_period}"

    cpu_utilization {
      target = "${var.autoscaler_cpu_utilization_target}"
    }
  }
}

# LB compute address

resource "google_compute_global_address" "address" {
  project = "${var.project_id}"
  name    = "cdn-ip"
}

# http health checks

resource "google_compute_health_check" "http_health_check" {
  project = "${var.project_id}"
  name    = "${var.health_check_name}"

  http_health_check {
    port = "80"
  }
}

# backend service

resource "google_compute_backend_service" "backend_service" {
  provider      = "google-beta"
  project       = "${var.project_id}"
  name          = "${var.backend_service_name}"
  protocol      = "HTTP"
  health_checks = ["${google_compute_health_check.http_health_check.self_link}"]

  backend {
    group           = "${google_compute_region_instance_group_manager.mig.instance_group}"
    balancing_mode  = "UTILIZATION"
    max_utilization = "0.8"
    capacity_scaler = "1"
  }
}

# url map

resource "google_compute_url_map" "url_map" {
  name            = "${var.url_map_name}"
  project         = "${var.project_id}"
  default_service = "${google_compute_backend_service.backend_service.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }

  path_matcher {
    name            = "allpaths"
    default_service = "${google_compute_backend_service.backend_service.self_link}"
  }
}

# http target proxy

resource "google_compute_target_http_proxy" "target_http_proxy" {
  project = "${var.project_id}"
  name    = "${var.target_proxy_name}"
  url_map = "${google_compute_url_map.url_map.self_link}"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "forwarding_rule" {
  provider    = "google-beta"
  name        = "${var.forwarding_rule_name}"
  target      = "${google_compute_target_http_proxy.target_http_proxy.self_link}"
  ip_address  = "${google_compute_global_address.address.address}"
  ip_protocol = "TCP"
  port_range  = "80"
}
