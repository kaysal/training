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
  machine_type = "f1-micro"
}

#============================================
# VPC Demo Configuration
#============================================

# vpc

resource "google_compute_network" "vpc_demo" {
  provider                = google-beta
  name                    = "${local.prefix}vpc-demo"
  routing_mode            = "REGIONAL"
  auto_create_subnetworks = "false"
}

# subnets

resource "google_compute_subnetwork" "vpc_demo_subnet_l7_ilb" {
  name                     = "${local.prefix}vpc-demo-subnet-l7-ilb"
  ip_cidr_range            = "10.1.12.0/24"
  region                   = "us-east1"
  network                  = google_compute_network.vpc_demo.self_link
  private_ip_google_access = false
  enable_flow_logs         = false
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

resource "google_compute_firewall" "vpc_demo_allow_http_ilb_tcp" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-allow-http-ilb-tcp"
  network  = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "tcp"
  }

  source_ranges = ["10.126.0.0/22"]
}

# instance templates

resource "google_compute_instance_template" "apache_instance_template" {
  project      = var.project_id
  name         = "apache-template"
  region       = "us-east1"
  machine_type = local.machine_type

  disk {
    source_image = local.image
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_demo_subnet_l7_ilb.self_link
    access_config {}
  }

  metadata_startup_script = "${file("scripts/apache.sh")}"

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance_template" "nginx_instance_template" {
  project      = var.project_id
  name         = "nginx-template"
  region       = "us-east1"
  machine_type = local.machine_type

  disk {
    source_image = local.image
    boot         = true
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vpc_demo_subnet_l7_ilb.self_link
    access_config {}
  }

  metadata_startup_script = "${file("scripts/nginx.sh")}"

  service_account {
    scopes = ["cloud-platform"]
  }
}
