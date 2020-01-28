# provider

provider "google" {}
provider "google-beta" {}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

locals {
  cloud = {
    network     = data.terraform_remote_state.vpc.outputs.networks.cloud.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.cloud.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.cloud.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.cloud.us_subnet
  }
}

# local variables

locals {
  ic_zone1_url = "https://www.googleapis.com/compute/v1/projects/${var.project_id_cloud}/global/interconnects/${var.cloud.eu.zone1.interconnect}"
  ic_zone2_url = "https://www.googleapis.com/compute/v1/projects/${var.project_id_cloud}/global/interconnects/${var.cloud.eu.zone2.interconnect}"
}

# zone1

## cloud router

resource "google_compute_router" "zone1_router" {
  project = var.project_id_cloud
  name    = "${var.cloud.prefix}zone1-router"
  network = local.cloud.network.self_link
  region  = var.cloud.eu.region
  bgp {
    asn            = var.cloud.asn
    advertise_mode = "CUSTOM"
    advertised_ip_ranges { range = local.cloud.eu_subnet.ip_cidr_range }
    advertised_ip_ranges { range = local.cloud.asia_subnet.ip_cidr_range }
    advertised_ip_ranges { range = local.cloud.us_subnet.ip_cidr_range }
  }
}

## interconnect attachment

resource "google_compute_interconnect_attachment" "zone1_vlan_100" {
  project           = var.project_id_cloud
  name              = "${var.cloud.prefix}zone1-vlan-100"
  interconnect      = local.ic_zone1_url
  type              = "DEDICATED"
  region            = var.cloud.eu.region
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = var.cloud.eu.zone2.vlan_id
  router            = google_compute_router.zone1_router.self_link
  candidate_subnets = [var.cloud.eu.zone1.candidate_subnets]
  admin_enabled     = true
}

## cloud router interface

resource "google_compute_router_interface" "zone1_vlan_100" {
  project                 = var.project_id_cloud
  region                  = var.cloud.eu.region
  name                    = "${var.cloud.prefix}zone1-vlan-100"
  interconnect_attachment = google_compute_interconnect_attachment.zone1_vlan_100.name
  router                  = google_compute_router.zone1_router.name
  ip_range                = var.cloud.eu.zone1.ip_range
}

## cloud router bgp peer

resource "google_compute_router_peer" "zone1_vlan_100" {
  project                   = var.project_id_cloud
  region                    = var.cloud.eu.region
  name                      = "${var.cloud.prefix}zone1-vlan-100"
  router                    = google_compute_router.zone1_router.name
  interface                 = google_compute_router_interface.zone1_vlan_100.name
  peer_ip_address           = var.cloud.eu.zone1.peer_ip_address
  peer_asn                  = var.cloud.eu.zone1.peer_asn
  advertised_route_priority = var.cloud.eu.zone1.advertised_route_priority
}

# zone2

resource "google_compute_router" "zone2_router" {
  project = var.project_id_cloud
  name    = "${var.cloud.prefix}zone2-router"
  network = local.cloud.network.self_link
  region  = var.cloud.eu.region
  bgp {
    asn            = var.cloud.asn
    advertise_mode = "CUSTOM"
    advertised_ip_ranges { range = local.cloud.eu_subnet.ip_cidr_range }
    advertised_ip_ranges { range = local.cloud.asia_subnet.ip_cidr_range }
    advertised_ip_ranges { range = local.cloud.us_subnet.ip_cidr_range }
  }
}

# interconnect attachment

resource "google_compute_interconnect_attachment" "zone2_vlan_100" {
  project           = var.project_id_cloud
  name              = "${var.cloud.prefix}zone2-vlan-100"
  interconnect      = local.ic_zone2_url
  type              = "DEDICATED"
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = var.cloud.eu.zone2.vlan_id
  region            = var.cloud.eu.region
  router            = google_compute_router.zone2_router.self_link
  candidate_subnets = [var.cloud.eu.zone2.candidate_subnets]
  admin_enabled     = true
}

## cloud router interface

resource "google_compute_router_interface" "zone2_vlan_100" {
  project                 = var.project_id_cloud
  region                  = var.cloud.eu.region
  name                    = "${var.cloud.prefix}zone2-vlan-100"
  interconnect_attachment = google_compute_interconnect_attachment.zone2_vlan_100.name
  router                  = google_compute_router.zone2_router.name
  ip_range                = var.cloud.eu.zone2.ip_range
}

## cloud router bgp peer

resource "google_compute_router_peer" "zone2_vlan_100" {
  project                   = var.project_id_cloud
  region                    = var.cloud.eu.region
  name                      = "${var.cloud.prefix}zone2-vlan-100"
  router                    = google_compute_router.zone2_router.name
  interface                 = google_compute_router_interface.zone2_vlan_100.name
  peer_ip_address           = var.cloud.eu.zone2.peer_ip_address
  peer_asn                  = var.cloud.eu.zone2.peer_asn
  advertised_route_priority = var.cloud.eu.zone2.advertised_route_priority
}
