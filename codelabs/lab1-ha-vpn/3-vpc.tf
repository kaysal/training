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

# onprem
#---------------------------------------------

# vpc

module "vpc_onprem" {
  source       = "../modules/vpc"
  network_name = "${local.onprem.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = "${local.onprem.prefix}-${local.onprem.subnet1}"
      subnet_ip                = "10.10.1.0/24"
      subnet_region            = local.onprem.region
      private_ip_google_access = false
    },
  ]

  secondary_ranges = {
    "${local.onprem.prefix}-${local.onprem.subnet1}" = []
  }
}

# firewall rules

resource "google_compute_firewall" "onprem_allow_ssh" {
  name    = "${local.onprem.prefix}allow-ssh"
  network = module.vpc_onprem.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "onprem_allow_icmp" {
  name    = "${local.onprem.prefix}allow-icmp"
  network = module.vpc_onprem.network.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8", "172.0.0.0/8", ]
}

# cloud
#---------------------------------------------

# vpc

module "vpc_cloud" {
  source       = "../modules/vpc"
  network_name = "${local.cloud.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = local.cloud.subnet1
      subnet_ip                = "172.16.1.0/24"
      subnet_region            = local.cloud.region
      private_ip_google_access = false
    },
  ]

  secondary_ranges = {
    "${local.cloud.subnet1}" = []
  }
}

# firewall rules

resource "google_compute_firewall" "cloud_allow_ssh" {
  name    = "${local.cloud.prefix}allow-ssh"
  network = module.vpc_cloud.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloud_allow_icmp" {
  name    = "${local.cloud.prefix}allow-icmp"
  network = module.vpc_cloud.network.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8", "172.0.0.0/8", ]
}
