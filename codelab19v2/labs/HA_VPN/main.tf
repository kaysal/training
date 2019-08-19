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

resource "google_compute_subnetwork" "vpc_demo_subnet_10_1_1" {
  name                     = "${local.prefix}vpc-demo-subnet-10-1-1"
  ip_cidr_range            = "10.1.1.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_demo.self_link
  private_ip_google_access = true
  enable_flow_logs         = true
}

resource "google_compute_subnetwork" "vpc_demo_subnet_10_3_1" {
  name                     = "${local.prefix}vpc-demo-subnet-10-3-1"
  ip_cidr_range            = "10.3.1.0/24"
  region                   = "us-east1"
  network                  = google_compute_network.vpc_demo.self_link
  private_ip_google_access = true
  enable_flow_logs         = true
}

# firewall rules

resource "google_compute_firewall" "vpc_demo_ssh" {
  provider    = google-beta
  name        = "${local.prefix}vpc-demo-ssh"
  description = "VPC demo SSH FW rule"
  network     = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpc_demo_icmp" {
  provider    = google-beta
  name        = "${local.prefix}vpc-demo-icmp"
  description = "VPC demo ICMP FW rule"
  network     = google_compute_network.vpc_demo.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}

# vm instances

module "vpc_demo_vm_10_1_1" {
  source                  = "../../modules/gce-public"
  project                 = var.project_id
  name                    = "${local.prefix}vpc-demo-vm-10-1-1"
  machine_type            = local.machine_type
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet_10_1_1.self_link
  tags                    = []
}

module "vpc_demo_vm_10_3_1" {
  source                  = "../../modules/gce-public"
  project                 = var.project_id
  name                    = "${local.prefix}vpc-demo-vm-10-3-1"
  machine_type            = local.machine_type
  zone                    = "us-east1-b"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet_10_3_1.self_link
  tags                    = []
}

#============================================
# VPC On-prem Configuration
#============================================

# vpc

resource "google_compute_network" "vpc_onprem" {
  provider                = google-beta
  name                    = "${local.prefix}vpc-onprem"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = "false"
}

# subnets

resource "google_compute_subnetwork" "vpc_onprem_subnet_10_128_1" {
  name                     = "${local.prefix}vpc-onprem-subnet-10-128-1"
  ip_cidr_range            = "10.128.1.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_onprem.self_link
  private_ip_google_access = false
  enable_flow_logs         = false
}

# firewall rules

resource "google_compute_firewall" "vpc_onprem_ssh" {
  provider    = google-beta
  name        = "${local.prefix}vpc-onprem-ssh"
  description = "VPC onprem SSH FW rule"
  network     = google_compute_network.vpc_onprem.self_link

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpc_onprem_icmp" {
  provider    = google-beta
  name        = "${local.prefix}vpc-onprem-icmp"
  description = "VPC onprem ICMP FW rule"
  network     = google_compute_network.vpc_onprem.self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8"]
}

# vm instances

module "vpc_onprem_vm" {
  source                  = "../../modules/gce-public"
  project                 = var.project_id
  name                    = "${local.prefix}vpc-onprem-vm"
  machine_type            = local.machine_type
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_onprem_subnet_10_128_1.self_link
  tags                    = []
}
