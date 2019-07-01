# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
