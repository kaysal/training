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

resource "google_compute_subnetwork" "vpc_demo_subnet1" {
  name                     = "${local.prefix}vpc-demo-subnet1"
  ip_cidr_range            = "10.1.1.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_demo.self_link
  private_ip_google_access = false
  enable_flow_logs         = false
}

resource "google_compute_subnetwork" "vpc_demo_subnet2" {
  name                     = "${local.prefix}vpc-demo-subnet2"
  ip_cidr_range            = "10.2.1.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_demo.self_link
  private_ip_google_access = false
  enable_flow_logs         = false
}

resource "google_compute_subnetwork" "vpc_demo_subnet3" {
  name                     = "${local.prefix}vpc-demo-subnet3"
  ip_cidr_range            = "10.3.1.0/24"
  region                   = "us-east1"
  network                  = google_compute_network.vpc_demo.self_link
  private_ip_google_access = false
  enable_flow_logs         = false
}

# firewall rules

resource "google_compute_firewall" "vpc_demo_allow_rfc1918" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-allow-rfc1918"
  network  = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16",
  ]
}

resource "google_compute_firewall" "vpc_demo_allow_ssh" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-allow-ssh"
  network  = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "tcp"
    ports    = [22]
  }
}

# vm instances

module "vpc_demo_vm1" {
  source                  = "../../modules/gce-private"
  project                 = var.project_id
  name                    = "${local.prefix}vpc-demo-vm1"
  machine_type            = local.machine_type
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet1.self_link
  tags                    = []
}

module "vpc_demo_vm2" {
  source                  = "../../modules/gce-private"
  project                 = var.project_id
  name                    = "${local.prefix}vpc-demo-vm2"
  machine_type            = local.machine_type
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet2.self_link
  tags                    = []
}

module "vpc_demo_vm3" {
  source                  = "../../modules/gce-private"
  project                 = var.project_id
  name                    = "${local.prefix}vpc-demo-vm3"
  machine_type            = local.machine_type
  zone                    = "us-east1-b"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet3.self_link
  tags                    = []
}
