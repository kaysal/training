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
  prefix = ""
}

#============================================
# VPC Demo Configuration
#============================================

# VPC Demo Network
#------------------------------

resource "google_compute_network" "vpc_demo" {
  provider                = "google-beta"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

# VPC Demo Cloud Routers
#------------------------------
resource "google_compute_router" "vpc_demo_cr_us_c1" {
  project = "${var.project_id}"
  name    = "${local.prefix}vpc-demo-cr-us-c1"
  network = "${google_compute_network.vpc_demo.self_link}"
  region  = "us-central1"

  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

    # gke private master range 1
    advertised_ip_ranges {
      range = "172.16.0.0/28"
    }

    # gke private master range 2
    advertised_ip_ranges {
      range = "172.16.0.32/28"
    }
  }
}

# VPC Demo VPNs
#-----------------------------------
# VPC_demo VPN GW external IP (us-central1)
resource "google_compute_address" "vpc_demo_vpngw_ip_us_c1" {
  project = "${var.project_id}"
  name    = "${local.prefix}vpc-demo-vpngw-ip-us-c1"
  region  = "us-central1"
}

# VPNGW and Tunnel in US Centra1
module "vpc_demo_vpn_us_c1" {
  source                   = "../../modules/vpn"
  project_id               = "${var.project_id}"
  prefix                   = "${local.prefix}"
  network                  = "${google_compute_network.vpc_demo.self_link}"
  region                   = "us-central1"
  gateway_name             = "vpc-demo-vpngw-us-c1"
  gateway_ip               = "${google_compute_address.vpc_demo_vpngw_ip_us_c1.address}"
  tunnel_name_prefix       = "vpc-demo-us-c1"
  shared_secret            = "${var.psk}"
  tunnel_count             = 1
  cr_name                  = "${google_compute_router.vpc_demo_cr_us_c1.name}"
  peer_asn                 = [64515]
  ike_version              = 2
  peer_ips                 = ["${google_compute_address.vpc_onprem_vpngw_ip_us_c1.address}"]
  bgp_cr_session_range     = ["169.254.100.1/30"]
  bgp_remote_session_range = ["169.254.100.2"]
}

#============================================
# VPC On-prem Configuration
#============================================

resource "google_compute_network" "vpc_onprem" {
  provider                = "google-beta"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-onprem"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

# Create vpc-onprem Cloud Router
resource "google_compute_router" "vpc_onprem_cr_us_c1" {
  project = "${var.project_id}"
  name    = "${local.prefix}vpc-onprem-cr-us-c1"
  network = "${google_compute_network.vpc_onprem.self_link}"
  region  = "us-central1"

  bgp {
    asn               = 64515
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# VPC On-premises VPN
#-----------------------------------
# VPC_onprem VPN GW external IP
resource "google_compute_address" "vpc_onprem_vpngw_ip_us_c1" {
  project = "${var.project_id}"
  name    = "${local.prefix}vpc-onprem-vpngw-ip-us-c1"
  region  = "us-central1"
}

module "vpc_onprem_vpn_us_c1" {
  source                   = "../../modules/vpn"
  project_id               = "${var.project_id}"
  prefix                   = "${local.prefix}"
  network                  = "${google_compute_network.vpc_onprem.self_link}"
  region                   = "us-central1"
  gateway_name             = "vpc-onprem-vpngw-us-c1"
  gateway_ip               = "${google_compute_address.vpc_onprem_vpngw_ip_us_c1.address}"
  tunnel_name_prefix       = "vpc-onprem"
  shared_secret            = "${var.psk}"
  tunnel_count             = 1
  cr_name                  = "${google_compute_router.vpc_onprem_cr_us_c1.name}"
  peer_asn                 = [64514]
  ike_version              = 2
  peer_ips                 = ["${google_compute_address.vpc_demo_vpngw_ip_us_c1.address}"]
  bgp_cr_session_range     = ["169.254.100.2/30"]
  bgp_remote_session_range = ["169.254.100.1"]
}
