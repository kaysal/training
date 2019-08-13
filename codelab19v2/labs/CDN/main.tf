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

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

locals {
  prefix       = ""
  image        = "debian-cloud/debian-9"
  machine_type = "n1-standard-1"
}

#============================================
# VPC Demo Configuration
#============================================

# vpc

resource "google_compute_network" "vpc_demo" {
  provider                = google-beta
  name                    = "${local.prefix}vpc-demo"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "vpc_demo_subnet1" {
  name          = "${local.prefix}vpc-demo-subnet-cdn"
  ip_cidr_range = "10.1.33.0/24"
  region        = "asia-east1"
  network       = google_compute_network.vpc_demo.self_link
}

# firewall rules

resource "google_compute_firewall" "vpc_demo_allow_internal" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-allow-internal"
  network  = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.1.0.0/16"]
}

resource "google_compute_firewall" "vpc_demo_allow_ssh_http_s_icmp" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-allow-ssh-http-s-icmp"
  network  = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "tcp"
    ports    = [22, 80, 443]
  }

  allow {
    protocol = "icmp"
  }
}

module "http_lb" {
  source                            = "../../modules/http_lb"
  project_id                        = var.project_id
  prefix                            = local.prefix
  instance_template_name            = "cdn-www-template"
  region                            = "asia-east1"
  machine_type                      = local.machine_type
  image                             = local.image
  subnetwork                        = google_compute_subnetwork.vpc_demo_subnet1.self_link
  metadata_startup_script           = "${file("scripts/startup.sh")}"
  instance_group_name               = "cdn-mig"
  target_size                       = 1
  autoscaler_max_replicas           = 3
  autoscaler_min_replicas           = 1
  autoscaler_cooldown_period        = 45
  autoscaler_cpu_utilization_target = "0.8"
  health_check_name                 = "http-basic-check"
  backend_service_name              = "cdn-backend-service"
  url_map_name                      = "cdn-map"
  target_proxy_name                 = "cdn-proxy"
  forwarding_rule_name              = "cdn-rule"
}

# cdn ip output

output "cdn-ip" {
  value = module.http_lb.cdn_ip
}
