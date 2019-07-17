/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

# vpc configuration

resource "google_compute_network" "network" {
  name                    = var.network_name
  auto_create_subnetworks = "false"
  routing_mode            = var.routing_mode
  project                 = var.project_id
}

# subnet

resource "google_compute_subnetwork" "subnetwork" {
  count = length(var.subnets)

  name                     = var.subnets[count.index].subnet_name
  ip_cidr_range            = var.subnets[count.index].subnet_ip
  region                   = var.subnets[count.index].subnet_region
  private_ip_google_access = lookup(var.subnets[count.index], "private_ip_google_access", "false")
  enable_flow_logs         = lookup(var.subnets[count.index], "enable_flow_logs", "false")
  network                  = google_compute_network.network.name
  project                  = var.project_id

  dynamic "secondary_ip_range" {
    for_each = var.secondary_ranges[var.subnets[count.index].subnet_name]
    content {
      ip_cidr_range = lookup(secondary_ip_range.value, "ip_cidr_range", null)
      range_name    = lookup(secondary_ip_range.value, "range_name", null)
    }
  }
}
