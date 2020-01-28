# provider

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

# local variables

data "terraform_remote_state" "default" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

locals {
  default      = data.terraform_remote_state.default.outputs.network.default
  ic_zone1_url = "https://www.googleapis.com/compute/v1/projects/${var.interconnect_project_id}/global/interconnects/${var.hub.default.eu.zone1.interconnect}"
  ic_zone2_url = "https://www.googleapis.com/compute/v1/projects/${var.interconnect_project_id}/global/interconnects/${var.hub.default.eu.zone2.interconnect}"
}

# zone1

## cloud router

resource "google_compute_router" "zone1_router" {
  project = var.project_id
  name    = "zone1-router"
  network = local.default.self_link
  region  = var.hub.default.eu.region
  bgp {
    asn               = var.hub.default.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

    advertised_ip_ranges {
      range = var.spoke.custom.asia.subnet
    }
    advertised_ip_ranges {
      range = var.spoke.custom.eu.subnet
    }
    advertised_ip_ranges {
      range = var.spoke.custom.us.subnet
    }
  }
}

## interconnect attachment

resource "google_compute_interconnect_attachment" "zone1_vlan_100" {
  project           = var.project_id
  name              = "zone1-vlan-100"
  interconnect      = local.ic_zone1_url
  type              = "DEDICATED"
  region            = var.hub.default.eu.region
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = var.hub.default.eu.zone2.vlan_id
  router            = google_compute_router.zone1_router.self_link
  candidate_subnets = [var.hub.default.eu.zone1.candidate_subnets]
  admin_enabled     = true

  lifecycle {
    ignore_changes = all
  }
}

## cloud router interface

resource "google_compute_router_interface" "zone1_vlan_100" {
  project                 = var.project_id
  region                  = var.hub.default.eu.region
  name                    = "zone1-vlan-100"
  interconnect_attachment = google_compute_interconnect_attachment.zone1_vlan_100.name
  router                  = google_compute_router.zone1_router.name
  ip_range                = var.hub.default.eu.zone1.ip_range
}

## cloud router bgp peer

resource "google_compute_router_peer" "zone1_vlan_100" {
  project                   = var.project_id
  region                    = var.hub.default.eu.region
  name                      = "zone1-vlan-100"
  router                    = google_compute_router.zone1_router.name
  interface                 = google_compute_router_interface.zone1_vlan_100.name
  peer_ip_address           = var.hub.default.eu.zone1.peer_ip_address
  peer_asn                  = var.hub.default.eu.zone1.peer_asn
  advertised_route_priority = var.hub.default.eu.zone1.advertised_route_priority
}

# zone2

resource "google_compute_router" "zone2_router" {
  project = var.project_id
  name    = "zone2-router"
  network = local.default.self_link
  region  = var.hub.default.eu.region
  bgp {
    asn               = var.hub.default.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

    advertised_ip_ranges {
      range = var.spoke.custom.asia.subnet
    }
    advertised_ip_ranges {
      range = var.spoke.custom.eu.subnet
    }
    advertised_ip_ranges {
      range = var.spoke.custom.us.subnet
    }
  }
}

## interconnect attachment

resource "google_compute_interconnect_attachment" "zone2_vlan_100" {
  project           = var.project_id
  name              = "zone2-vlan-100"
  interconnect      = local.ic_zone2_url
  type              = "DEDICATED"
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = var.hub.default.eu.zone2.vlan_id
  region            = var.hub.default.eu.region
  router            = google_compute_router.zone2_router.self_link
  candidate_subnets = [var.hub.default.eu.zone2.candidate_subnets]
  admin_enabled     = true

  lifecycle {
    ignore_changes = all
  }
}

## cloud router interface

resource "google_compute_router_interface" "zone2_vlan_100" {
  project                 = var.project_id
  region                  = var.hub.default.eu.region
  name                    = "zone2-vlan-100"
  interconnect_attachment = google_compute_interconnect_attachment.zone2_vlan_100.name
  router                  = google_compute_router.zone2_router.name
  ip_range                = var.hub.default.eu.zone2.ip_range
}

## cloud router bgp peer

resource "google_compute_router_peer" "zone2_vlan_100" {
  project                   = var.project_id
  region                    = var.hub.default.eu.region
  name                      = "zone2-vlan-100"
  router                    = google_compute_router.zone2_router.name
  interface                 = google_compute_router_interface.zone2_vlan_100.name
  peer_ip_address           = var.hub.default.eu.zone2.peer_ip_address
  peer_asn                  = var.hub.default.eu.zone2.peer_asn
  advertised_route_priority = var.hub.default.eu.zone2.advertised_route_priority
}
