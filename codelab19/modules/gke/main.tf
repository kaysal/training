# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_container_cluster" "cluster" {
  provider           = "google-beta"
  name               = "${var.name}"
  region             = "${var.region}"
  additional_zones   = ["${var.zones}"]
  network            = "${var.network}"
  subnetwork         = "${var.subnetwork}"
  project            = "${var.project_id}"
  min_master_version = "${var.min_master_version}"
  initial_node_count = "${var.node_count}"
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  resource_labels    = "${var.cluster_labels}"

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.pods_range}"
    services_secondary_range_name = "${var.services_range}"
  }

  network_policy {
    enabled = "${var.network_policy}"
  }

  # master_authorized_networks_config
  # master_ipv4_cidr_block
  # private_cluster

  node_config {
    service_account = "${var.service_account}"
    oauth_scopes    = "${var.oauth_scopes}"
    tags            = "${var.network_tags}"
    labels          = "${var.cluster_labels}"

    # taints need the google beta provider
    taint = "${var.node_taints}"
  }
  maintenance_policy {
    daily_maintenance_window {
      start_time = "${var.maintenance_window_utc}"
    }
  }
  addons_config {
    kubernetes_dashboard {
      disabled = true
    }
  }
  # Disable cert-based + static username based auth
  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }

    username = ""
    password = ""
  }
  timeouts {
    update = "20m"
    delete = "20m"
  }

  # this breaks on subsequent apply
  # remove_default_node_pool = "${var.node_count == 0 ? true : false}"
}
