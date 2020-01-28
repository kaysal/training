# provider

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# data

data "terraform_remote_state" "attachment_data" {
  backend = "local"

  config = {
    path = "../2-attachment/terraform.tfstate"
  }
}

locals {
  prod_router1      = data.terraform_remote_state.attachment_data.outputs.attachment.prod_router1
  prod_router2      = data.terraform_remote_state.attachment_data.outputs.attachment.prod_router2
  prod_ic3_vlan_100 = data.terraform_remote_state.attachment_data.outputs.attachment.prod_ic3_vlan_100
  prod_ic4_vlan_100 = data.terraform_remote_state.attachment_data.outputs.attachment.prod_ic4_vlan_100
}

# interconnect zone1

## cloud router interface

resource "google_compute_router_interface" "prod_router1" {
  region                  = "europe-west2"
  name                    = "${var.prefix}prod-router1"
  interconnect_attachment = local.prod_ic3_vlan_100.name
  router                  = local.prod_router1.name
  ip_range                = "169.254.30.1/29"
}

## bgp peer configuration

resource "google_compute_router_peer" "prod_router1" {
  region                    = "europe-west2"
  name                      = "${var.prefix}prod-router1"
  router                    = local.prod_router1.name
  interface                 = google_compute_router_interface.prod_router1.name
  peer_ip_address           = "169.254.30.2"
  peer_asn                  = "64500"
  advertised_route_priority = "100"
}

# interconnect zone2

## cloud router interface

resource "google_compute_router_interface" "prod_router2" {
  region                  = "europe-west2"
  name                    = "${var.prefix}prod-router2"
  interconnect_attachment = local.prod_ic4_vlan_100.name
  router                  = local.prod_router2.name
  ip_range                = "169.254.40.1/29"
}

## bgp peer configuration

resource "google_compute_router_peer" "prod_router2" {
  region                    = "europe-west2"
  name                      = "${var.prefix}prod-router2"
  router                    = local.prod_router2.name
  interface                 = google_compute_router_interface.prod_router2.name
  peer_ip_address           = "169.254.40.2"
  peer_asn                  = "64500"
  advertised_route_priority = "100"
}
