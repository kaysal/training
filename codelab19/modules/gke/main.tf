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
  provider                    = "google-beta"
  project                     = "${var.project_id}"
  name                        = "${var.name}"
  location                    = "${var.location}"
  node_locations              = ["${var.node_locations}"]
  network                     = "${var.network}"
  subnetwork                  = "${var.subnetwork}"
  min_master_version          = "${var.min_master_version}"
  initial_node_count          = "${var.node_count}"
  logging_service             = "logging.googleapis.com/kubernetes"
  monitoring_service          = "monitoring.googleapis.com/kubernetes"
  resource_labels             = "${var.cluster_labels}"
  default_max_pods_per_node   = "${var.default_max_pods_per_node}"
  enable_binary_authorization = "${var.enable_binary_authorization}"

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.pods_range}"
    services_secondary_range_name = "${var.services_range}"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "${var.maintenance_window_utc}"
    }
  }

  addons_config {
    network_policy_config {
      disabled = "${var.network_policy_config_disabled}"
    }

    kubernetes_dashboard {
      disabled = "${var.kubernetes_dashboard_disabled}"
    }

    istio_config {
      disabled = "${var.istio_config_disabled}"

      #auth = "AUTH_MUTUAL_TLS"
    }
  }

  network_policy {
    provider = "CALICO"
    enabled  = "${var.network_policy_enabled}"
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

resource "google_container_node_pool" "node_pool" {
  provider   = "google-beta"
  name       = "${var.name}"
  cluster    = "${google_container_cluster.cluster.name}"
  location   = "${var.location}"
  node_count = "${var.node_count}"

  node_config {
    machine_type    = "${var.machine_type}"
    service_account = "${var.service_account}"
    tags            = ["${var.network_tags}"]
    oauth_scopes    = ["${var.oauth_scopes}"]
    labels          = "${var.node_labels}"
    taint           = "${var.node_taints}"

    workload_metadata_config {
      node_metadata = "${var.node_metadata}"
    }
  }
}
