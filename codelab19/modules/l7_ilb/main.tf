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
  project                   = "${var.project_id}"
  name                      = "${var.instance_group_name}"
  base_instance_name        = "${var.instance_group_name}"
  instance_template         = "${google_compute_instance_template.instance_template.self_link}"
  region                    = "${var.region}"
  distribution_policy_zones = "${var.distribution_policy_zones}"
  target_size               = "${var.target_size}"
}
