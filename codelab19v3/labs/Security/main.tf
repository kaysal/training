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
  image        = "projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20190404"
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
  name                     = "${local.prefix}vpc-demo-subnet-10-1-1"
  ip_cidr_range            = "10.1.1.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_demo.self_link
  private_ip_google_access = "true"

  secondary_ip_range {
    range_name    = "pod-range"
    ip_cidr_range = "10.4.1.0/24"
  }

  secondary_ip_range {
    range_name    = "svc-range"
    ip_cidr_range = "10.5.1.0/24"
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
  }
}

resource "google_compute_subnetwork" "vpc_demo_subnet_10_2_1" {
  name                     = "${local.prefix}vpc-demo-subnet-10-2-1"
  ip_cidr_range            = "10.2.1.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_demo.self_link
  private_ip_google_access = "false"

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
  }
}

resource "google_compute_subnetwork" "vpc_demo_subnet_10_3_1" {
  name                     = "${local.prefix}vpc-demo-subnet-10-3-1"
  ip_cidr_range            = "10.3.1.0/24"
  region                   = "us-east1"
  network                  = google_compute_network.vpc_demo.self_link
  private_ip_google_access = "true"

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
  }
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
  source                  = "../../modules/gce-private"
  project                 = var.project_id
  name                    = "${local.prefix}vpc-demo-vm-10-1-1"
  machine_type            = local.machine_type
  zone                    = "us-central1-a"
  metadata_startup_script = file("scripts/startup.sh")
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet_10_1_1.self_link
}

module "vpc_demo_vm_10_2_1" {
  source                  = "../../modules/gce-private"
  project                 = var.project_id
  name                    = "${local.prefix}vpc-demo-vm-10-2-1"
  machine_type            = local.machine_type
  zone                    = "us-central1-a"
  metadata_startup_script = file("scripts/startup.sh")
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet_10_2_1.self_link
}

module "vpc_demo_vm_10_3_1" {
  source                  = "../../modules/gce-private"
  project                 = var.project_id
  name                    = "${local.prefix}vpc-demo-vm-10-3-1"
  machine_type            = local.machine_type
  zone                    = "us-east1-b"
  metadata_startup_script = file("scripts/startup.sh")
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_demo_subnet_10_3_1.self_link
}

# cloud routers

resource "google_compute_router" "vpc_demo_cr_us_c1" {
  name    = "${local.prefix}vpc-demo-cr-us-c1"
  network = google_compute_network.vpc_demo.self_link
  region  = "us-central1"

  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

    # restricted google api range
    advertised_ip_ranges {
      range = "199.36.153.4/30"
    }
  }
}

resource "google_compute_router" "vpc_demo_cr_us_e1" {
  name    = "${local.prefix}vpc-demo-cr-us-e1"
  network = google_compute_network.vpc_demo.self_link
  region  = "us-east1"

  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}


# VPN GW external IP us-central1

resource "google_compute_address" "vpc_demo_vpngw_ip_us_c1" {
  name   = "${local.prefix}vpc-demo-vpngw-ip-us-c1"
  region = "us-central1"
}

# VPN GW external IP us-east1

resource "google_compute_address" "vpc_demo_vpngw_ip_us_e1" {
  name   = "${local.prefix}vpc-demo-vpngw-ip-us-e1"
  region = "us-east1"
}

# VPNGW and Tunnel in us-central1


# VPNGW and Tunnel in US Centra1
module "vpc_demo_vpn_us_c1" {
  source                   = "../../modules/vpn-classic"
  project_id               = var.project_id
  prefix                   = local.prefix
  network                  = google_compute_network.vpc_demo.self_link
  region                   = "us-central1"
  gateway_name             = "vpc-demo-vpngw-us-c1"
  gateway_ip               = google_compute_address.vpc_demo_vpngw_ip_us_c1.address
  tunnel_name_prefix       = "vpc-demo-us-c1"
  shared_secret            = var.psk
  tunnel_count             = 1
  cr_name                  = google_compute_router.vpc_demo_cr_us_c1.name
  peer_asn                 = [64515]
  ike_version              = 2
  peer_ips                 = [google_compute_address.vpc_onprem_vpngw_ip_us_c1.address]
  bgp_cr_session_range     = ["169.254.100.1/30"]
  bgp_remote_session_range = ["169.254.100.2"]
}

# VPNGW and Tunnel in us-east1

module "vpc_demo_vpn_us_e1" {
  source                   = "../../modules/vpn-classic"
  project_id               = var.project_id
  prefix                   = local.prefix
  network                  = google_compute_network.vpc_demo.self_link
  region                   = "us-east1"
  gateway_name             = "vpc-demo-vpngw-us-e1"
  gateway_ip               = google_compute_address.vpc_demo_vpngw_ip_us_e1.address
  tunnel_name_prefix       = "vpc-demo-us-e1"
  shared_secret            = var.psk
  tunnel_count             = 1
  cr_name                  = google_compute_router.vpc_demo_cr_us_e1.name
  peer_asn                 = [64515]
  ike_version              = 2
  peer_ips                 = [google_compute_address.vpc_onprem_vpngw_ip_us_c1.address]
  bgp_cr_session_range     = ["169.254.100.5/30"]
  bgp_remote_session_range = ["169.254.100.6"]
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

resource "google_compute_subnetwork" "vpc_onprem_subnet_10_10_10" {
  name                     = "${local.prefix}vpc-onprem-subnet-10-10-10"
  ip_cidr_range            = "10.10.10.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.vpc_onprem.self_link
  private_ip_google_access = false
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

module "vpc_onprem_vm_10_10_10" {
  project                 = var.project_id
  source                  = "../../modules/gce-private"
  name                    = "${local.prefix}vpc-onprem-vm-10-10-10"
  machine_type            = local.machine_type
  zone                    = "us-central1-a"
  metadata_startup_script = file("scripts/startup.sh")
  image                   = local.image
  subnetwork              = google_compute_subnetwork.vpc_onprem_subnet_10_10_10.self_link
}

# cloud routers

resource "google_compute_router" "vpc_onprem_cr_us_c1" {
  name    = "${local.prefix}vpc-onprem-cr-us-c1"
  network = google_compute_network.vpc_onprem.self_link
  region  = "us-central1"

  bgp {
    asn            = 64515
    advertise_mode = "CUSTOM"

    advertised_ip_ranges {
      range = google_compute_subnetwork.vpc_onprem_subnet_10_10_10.ip_cidr_range
    }
  }
}

# VPC On-premises VPN
#-----------------------------------
# VPC_onprem VPN GW external IP
resource "google_compute_address" "vpc_onprem_vpngw_ip_us_c1" {
  name   = "${local.prefix}vpc-onprem-vpngw-ip-us-c1"
  region = "us-central1"
}

module "vpc_onprem_vpn_us_c1" {
  source             = "../../modules/vpn-classic"
  project_id         = var.project_id
  prefix             = local.prefix
  network            = google_compute_network.vpc_onprem.self_link
  region             = "us-central1"
  gateway_name       = "vpc-onprem-vpngw-us-c1"
  gateway_ip         = google_compute_address.vpc_onprem_vpngw_ip_us_c1.address
  tunnel_name_prefix = "vpc-onprem"
  shared_secret      = var.psk
  tunnel_count       = 2
  cr_name            = google_compute_router.vpc_onprem_cr_us_c1.name
  peer_asn           = [64514, 64514]
  ike_version        = 2

  peer_ips = [
    google_compute_address.vpc_demo_vpngw_ip_us_c1.address,
    google_compute_address.vpc_demo_vpngw_ip_us_e1.address,
  ]

  bgp_cr_session_range     = ["169.254.100.2/30", "169.254.100.6/30"]
  bgp_remote_session_range = ["169.254.100.1", "169.254.100.5"]
}
