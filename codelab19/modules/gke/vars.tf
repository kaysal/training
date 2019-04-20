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

variable "name" {
  description = "Cluster name."
}

variable "region" {
  description = "Cluster region."
}

variable "zones" {
  description = "Cluster zones."
  type        = "list"
}

variable "network" {
  description = "Cluster network."
}

variable "subnetwork" {
  description = "Cluster subnetwork."
}

variable "pods_range" {
  description = "Name of the alias IP range for pods."
}

variable "services_range" {
  description = "Name of the alias IP range for services."
}

variable "project_id" {
  description = "Cluster project."
}

variable "min_master_version" {
  description = "Minimum version for master."
  default     = "1.10.5-gke.3"
}

variable "network_policy" {
  description = "Enable network policy."
  default     = false
}

variable "maintenance_window_utc" {
  description = "Maintenance window of the cluster itself, in UTC time."
  default     = "04:00"
}

variable "cluster_labels" {
  type        = "map"
  description = "Labels to be attached to the cluster."

  default = {
    component = "gke"
  }
}

variable "node_count" {
  description = "Initial node count."
  default     = 1
}

# node configuration attributes here
# https://www.terraform.io/docs/providers/google/r/container_cluster.html#disk_size_gb

variable "service_account" {
  description = "The service account to use for the default nodes in the cluster."
  default     = "default"
}

variable "oauth_scopes" {
  description = "Scopes for the nodes service account."
  type        = "list"

  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]
}

# Changing network tags recreates the cluster!
variable "network_tags" {
  type        = "list"
  description = "Network tags to be attached to the cluster VMs, for firewall rules."
  default     = []
}

/* node_taints = [{
  key    = "taints.xxx.com_node-allocation"
  value  = "default-nodepool"
  effect = "PREFER_NO_SCHEDULE"
}] */
variable "node_taints" {
  type        = "list"
  description = "Taints applied to default nodes. List of maps."
  default     = []
}
