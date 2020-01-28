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
  prefix = ""
}

#============================================
# VPC Demo Configuration
#============================================

# vpc

resource "google_compute_network" "vpc_demo" {
  provider                = google-beta
  name                    = "${local.prefix}vpc-demo"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = "false"
}

# subnets

resource "google_compute_subnetwork" "vpc_demo_subnet1" {
  name          = "${local.prefix}vpc-demo-subnet1"
  ip_cidr_range = "10.1.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_demo.self_link
}

resource "google_compute_subnetwork" "vpc_demo_subnet2" {
  name          = "${local.prefix}vpc-demo-subnet2"
  ip_cidr_range = "10.2.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_demo.self_link
}

resource "google_compute_subnetwork" "vpc_demo_subnet3" {
  name          = "${local.prefix}vpc-demo-subnet3"
  ip_cidr_range = "10.3.1.0/24"
  region        = "us-east1"
  network       = google_compute_network.vpc_demo.self_link
}

# firewall rules

resource "google_compute_firewall" "vpc_demo_allow_health_checks" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-allow-health-checks"
  network  = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "tcp"
    ports    = [80, 8000]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]
}

# FW rule for HTTP from RFC1918

resource "google_compute_firewall" "vpc_demo_allow_http_rfc1918" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-allow-http-rfc1918"
  network  = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "tcp"
    ports    = [80, 8000]
  }

  source_ranges = [
    "10.0.0.0/8",
    "192.168.0.0/16",
  ]
}
