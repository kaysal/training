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
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

# cloud router

resource "google_compute_router" "vpc_demo_cr_us_c1" {
  name    = "${local.prefix}vpc-demo-cr-us-c1"
  network = google_compute_network.vpc_demo.self_link
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

# vpn gateway

resource "google_compute_ha_vpn_gateway" "vpc_demo_vpngw_us_c1" {
  provider = "google-beta"
  region   = "us-central1"
  name     = "${local.prefix}vpc-demo-vpngw-us-c1"
  network  = google_compute_network.vpc_demo.self_link
}

# vpn tunnel

module "vpn_demo_to_onprem" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = google_compute_network.vpc_demo.self_link
  region           = "us-central1"
  vpn_gateway      = google_compute_ha_vpn_gateway.vpc_demo_vpngw_us_c1.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.vpc_onprem_vpngw_us_c1.self_link
  shared_secret    = var.psk
  router           = google_compute_router.vpc_demo_cr_us_c1.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${local.prefix}demo-to-onprem"
      peer_asn                  = 64515
      cr_bgp_session_range      = "169.254.100.1/30"
      remote_bgp_session_ip     = "169.254.100.2"
      advertised_route_priority = 100
    },
    {
      session_name              = "${local.prefix}demo-to-onprem"
      peer_asn                  = 64515
      cr_bgp_session_range      = "169.254.100.5/30"
      remote_bgp_session_ip     = "169.254.100.6"
      advertised_route_priority = 100
    },
  ]
}

#============================================
# VPC On-prem Configuration
#============================================

# vpc

resource "google_compute_network" "vpc_onprem" {
  provider                = "google-beta"
  name                    = "${local.prefix}vpc-onprem"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}

# cloud router

resource "google_compute_router" "vpc_onprem_cr_us_c1" {
  name    = "${local.prefix}vpc-onprem-cr-us-c1"
  network = google_compute_network.vpc_onprem.self_link
  region  = "us-central1"

  bgp {
    asn               = 64515
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# vpn gateway

resource "google_compute_ha_vpn_gateway" "vpc_onprem_vpngw_us_c1" {
  provider = "google-beta"
  region   = "us-central1"
  name     = "${local.prefix}vpc-onprem-vpngw-us-c1"
  network  = google_compute_network.vpc_onprem.self_link
}

# vpn tunnel

module "vpn_onprem_to_demo" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = google_compute_network.vpc_onprem.self_link
  region           = "us-central1"
  vpn_gateway      = google_compute_ha_vpn_gateway.vpc_onprem_vpngw_us_c1.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.vpc_demo_vpngw_us_c1.self_link
  shared_secret    = var.psk
  router           = google_compute_router.vpc_onprem_cr_us_c1.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${local.prefix}onprem-to-demo"
      peer_asn                  = 64514
      cr_bgp_session_range      = "169.254.100.2/30"
      remote_bgp_session_ip     = "169.254.100.1"
      advertised_route_priority = 100
    },
    {
      session_name              = "${local.prefix}onprem-to-demo"
      peer_asn                  = 64514
      cr_bgp_session_range      = "169.254.100.6/30"
      remote_bgp_session_ip     = "169.254.100.5"
      advertised_route_priority = 100
    },
  ]
}
