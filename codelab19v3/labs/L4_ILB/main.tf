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
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = "false"
}

# subnets

resource "google_compute_subnetwork" "vpc_demo_subnet_10_1_1" {
  name                     = "${local.prefix}vpc-demo-subnet1"
  ip_cidr_range            = "10.1.1.0/24"
  region                   = "us-central1"
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

resource "google_compute_firewall" "vpc_demo_allow_health_checks" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-allow-health-checks"
  network  = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "tcp"
    ports    = [80]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["allow-hc"]
}

resource "google_compute_firewall" "vpc_demo_allow_ssh" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-allow-ssh"
  network  = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  target_tags = ["allow-ssh"]
}

# vm instances

module "vm_primary_a" {
  source                  = "../../modules/gce-public"
  project                 = var.project_id
  name                    = "${local.prefix}vm-primary-a"
  machine_type            = local.machine_type
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet_10_1_1.self_link
  tags                    = ["allow-hc"]
}

module "vm_primary_b" {
  source                  = "../../modules/gce-public"
  project                 = var.project_id
  name                    = "${local.prefix}vm-primary-b"
  machine_type            = local.machine_type
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet_10_1_1.self_link
  tags                    = ["allow-hc"]
}

module "vm_backup" {
  source                  = "../../modules/gce-public"
  project                 = var.project_id
  name                    = "${local.prefix}vm-backup"
  machine_type            = local.machine_type
  zone                    = "us-central1-c"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet_10_1_1.self_link
  tags                    = ["allow-hc"]
}

module "vm_client" {
  source                  = "../../modules/gce-public"
  project                 = var.project_id
  name                    = "${local.prefix}vm-client"
  machine_type            = local.machine_type
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/client.sh")}"
  image                   = local.image
  subnetwork_project      = var.project_id
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet_10_1_1.self_link
  tags                    = ["allow-ssh"]
}
