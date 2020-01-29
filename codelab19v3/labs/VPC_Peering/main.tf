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

provider google-beta {
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
  auto_create_subnetworks = false
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
  region        = "us-east1"
  network       = google_compute_network.vpc_demo.self_link
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
    "192.168.0.0/16"
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

# cloud routers

resource "google_compute_router" "vpc_demo_cr_us_c1" {
  name    = "${local.prefix}vpc-demo-cr-us-c1"
  network = google_compute_network.vpc_demo.self_link
  region  = "us-central1"

  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# public ip

resource "google_compute_address" "vpc_demo_vpngw_ip_us_c1" {
  name   = "${local.prefix}vpc-demo-vpngw-ip-us-c1"
  region = "us-central1"
}

# VPNGW and Tunnel in us-central1

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

resource "google_compute_route" "route_to_onprem_subnet2" {
  name                = "${local.prefix}route-to-onprem-subnet2"
  dest_range          = "172.16.2.0/24"
  network             = google_compute_network.vpc_demo.self_link
  next_hop_vpn_tunnel = module.vpc_demo_vpn_us_c1.vpn_tunnels.0.self_link
  priority            = 100
}

#============================================
# VPC On-prem Configuration
#============================================

# vpc

resource "google_compute_network" "vpc_onprem" {
  provider                = google-beta
  name                    = "${local.prefix}vpc-onprem"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "onprem_subnet1" {
  name          = "${local.prefix}onprem-subnet1"
  ip_cidr_range = "172.16.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_onprem.self_link
}

resource "google_compute_subnetwork" "onprem_subnet2" {
  name          = "${local.prefix}onprem-subnet2"
  ip_cidr_range = "172.16.2.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_onprem.self_link
}

# firewall rules

resource "google_compute_firewall" "vpc_onprem_allow_rfc1918" {
  provider = google-beta
  name     = "${local.prefix}vpc-onprem-allow-rfc1918"
  network  = google_compute_network.vpc_onprem.self_link

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

resource "google_compute_firewall" "vpc_onprem_allow_ssh" {
  provider = google-beta
  name     = "${local.prefix}vpc-onprem-allow-ssh"
  network  = google_compute_network.vpc_onprem.self_link

  allow {
    protocol = "tcp"
    ports    = [22]
  }
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
      range = google_compute_subnetwork.onprem_subnet1.ip_cidr_range
    }
  }
}

# VPN GW external IP us-east1

resource "google_compute_address" "vpc_onprem_vpngw_ip_us_c1" {
  name   = "${local.prefix}vpc-onprem-vpngw-ip-us-c1"
  region = "us-central1"
}

module "vpc_onprem_vpn_us_c1" {
  source                   = "../../modules/vpn-classic"
  project_id               = var.project_id
  prefix                   = local.prefix
  network                  = google_compute_network.vpc_onprem.self_link
  region                   = "us-central1"
  gateway_name             = "vpc-onprem-vpngw-us-c1"
  gateway_ip               = google_compute_address.vpc_onprem_vpngw_ip_us_c1.address
  tunnel_name_prefix       = "vpc-onprem"
  shared_secret            = var.psk
  tunnel_count             = 1
  cr_name                  = google_compute_router.vpc_onprem_cr_us_c1.name
  peer_asn                 = [64514]
  ike_version              = 2
  peer_ips                 = [google_compute_address.vpc_demo_vpngw_ip_us_c1.address]
  bgp_cr_session_range     = ["169.254.100.2/30"]
  bgp_remote_session_range = ["169.254.100.1"]
}

#============================================
# VPC Demo 2 Configuration
#============================================

# vpc

resource "google_compute_network" "vpc_demo_2" {
  provider                = google-beta
  name                    = "${local.prefix}vpc-demo-2"
  routing_mode            = "GLOBAL"
  auto_create_subnetworks = false
}

# subnets

resource "google_compute_subnetwork" "vpc_demo_2_subnet1" {
  name          = "${local.prefix}vpc-demo-2-subnet1"
  ip_cidr_range = "10.3.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_demo_2.self_link
}

# firewall rules

resource "google_compute_firewall" "vpc_demo_2_allow_rfc1918" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-2-allow-rfc1918"
  network  = google_compute_network.vpc_demo_2.self_link

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

resource "google_compute_firewall" "vpc_demo_2_allow_ssh" {
  provider = google-beta
  name     = "${local.prefix}vpc-demo-2-allow-ssh"
  network  = google_compute_network.vpc_demo_2.self_link

  allow {
    protocol = "tcp"
    ports    = [22]
  }
}
