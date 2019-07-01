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

provider "google" {}

provider "google-beta" {}

locals {
  prefix       = ""
  image        = "debian-cloud/debian-9"
  machine_type = "f1-micro"
}

#============================================
# VPC Demo Configuration
#============================================

# VPC Demo Network

locals {
  vpc_demo_subnet1 = "${local.prefix}vpc-demo-subnet1"
  vpc_demo_subnet2 = "${local.prefix}vpc-demo-subnet2"
  vpc_demo_subnet3 = "${local.prefix}vpc-demo-subnet3"
}

module "vpc_demo" {
  source  = "terraform-google-modules/network/google"
  version = "0.6.0"

  project_id   = "${var.project_id}"
  network_name = "${local.prefix}vpc-demo"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_demo_subnet1}"
      subnet_ip             = "10.1.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "${local.vpc_demo_subnet2}"
      subnet_ip             = "10.2.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "${local.vpc_demo_subnet3}"
      subnet_ip             = "10.3.1.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
  ]

  secondary_ranges = {
    "${local.vpc_demo_subnet1}" = []
    "${local.vpc_demo_subnet2}" = []
    "${local.vpc_demo_subnet3}" = []
  }
}

# FW Rules

resource "google_compute_firewall" "vpc_demo_allow_rfc1918" {
  provider = "google-beta"
  name     = "${local.prefix}vpc-demo-allow-rfc1918"
  network  = "${module.vpc_demo.network_self_link}"

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
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "vpc_demo_allow_ssh" {
  provider = "google-beta"
  name     = "${local.prefix}vpc-demo-allow-ssh"
  network  = "${module.vpc_demo.network_self_link}"

  allow {
    protocol = "tcp"
    ports    = [22]
  }
}

# VM Instance

module "vpc_demo_vm1" {
  source                  = "../../modules/gce-private"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo-vm1"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_demo.subnets_self_links[0]}"
}

module "vpc_demo_vm2" {
  source                  = "../../modules/gce-private"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo-vm2"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_demo.subnets_self_links[1]}"
}

module "vpc_demo_vm3" {
  source                  = "../../modules/gce-private"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo-vm3"
  machine_type            = "${local.machine_type}"
  zone                    = "us-east1-b"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_demo.subnets_self_links[2]}"
}
