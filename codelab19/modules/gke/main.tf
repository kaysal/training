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

resource "google_container_cluster" "cluster" {
  provider                          = "google-beta"
  project                           = "${var.project_id}"
  name                              = "${var.name}"
  min_master_version                = "${var.min_master_version}"
  network                           = "${var.network}"
  subnetwork                        = "${var.subnetwork}"
  location                          = "${var.location}"
  default_max_pods_per_node         = "${var.default_max_pods_per_node}"
  remove_default_node_pool          = "${var.remove_default_node_pool}"
  logging_service                   = "${var.logging_service}"
  monitoring_service                = "${var.monitoring_service}"
  enable_binary_authorization       = "${var.enable_binary_authorization}"
  initial_node_count                = "${var.node_count}"
  resource_labels                   = "${var.cluster_labels}"
  master_authorized_networks_config = "${var.master_authorized_networks_config}"

  private_cluster_config {
    enable_private_endpoint = "${var.enable_private_endpoint}"
    enable_private_nodes    = "${var.enable_private_nodes}"
    master_ipv4_cidr_block  = "${var.master_ipv4_cidr_block}"
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.pods_range_name}"
    services_secondary_range_name = "${var.services_range_name}"
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

    workload_metadata_config {
      node_metadata = "${var.node_metadata}"
    }
  }
}
