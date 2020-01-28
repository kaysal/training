provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

provider "random" {}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "router" {
  backend = "local"

  config = {
    path = "../3-router/terraform.tfstate"
  }
}

locals {
  onprem = { network = data.terraform_remote_state.vpc.outputs.networks.onprem }
  hub    = { network = data.terraform_remote_state.vpc.outputs.networks.hub }
  spoke1 = { network = data.terraform_remote_state.vpc.outputs.networks.spoke1 }
  spoke2 = { network = data.terraform_remote_state.vpc.outputs.networks.spoke2 }
}

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# onprem
#---------------------------------------------

# vpn gateways

## ha vpn gateway

resource "google_compute_ha_vpn_gateway" "onprem_ha_vpn_a" {
  provider = "google-beta"
  region   = var.onprem.region_a
  name     = "${var.onprem.prefix}ha-vpn-a"
  network  = local.onprem.network.self_link
}

resource "google_compute_ha_vpn_gateway" "onprem_ha_vpn_b" {
  provider = "google-beta"
  region   = var.onprem.region_b
  name     = "${var.onprem.prefix}ha-vpn-b"
  network  = local.onprem.network.self_link
}

# hub
#---------------------------------------------

# ha vpn

## gateways

resource "google_compute_ha_vpn_gateway" "hub_ha_vpn_a" {
  provider = "google-beta"
  region   = var.hub.region_a
  name     = "${var.hub.prefix}ha-vpn-a"
  network  = local.hub.network.self_link
}

resource "google_compute_ha_vpn_gateway" "hub_ha_vpn_b" {
  provider = "google-beta"
  region   = var.hub.region_b
  name     = "${var.hub.prefix}ha-vpn-b"
  network  = local.hub.network.self_link
}

# classic vpn

## gateways

module "vpn_gw_hub_a" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id
  prefix       = var.hub.prefix
  network      = local.hub.network.self_link
  region       = var.hub.region_a
  gateway_name = "vpn-a"
}

module "vpn_gw_hub_b" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id
  prefix       = var.hub.prefix
  network      = local.hub.network.self_link
  region       = var.hub.region_b
  gateway_name = "vpn-b"
}

# spoke1
#---------------------------------------------

# classic vpn

## gateways

module "vpn_gw_spoke1_a" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id
  prefix       = var.spoke1.prefix
  network      = local.spoke1.network.self_link
  region       = var.spoke1.region_a
  gateway_name = "vpn-a"
}

module "vpn_gw_spoke1_b" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id
  prefix       = var.spoke1.prefix
  network      = local.spoke1.network.self_link
  region       = var.spoke1.region_b
  gateway_name = "vpn-b"
}

# spoke2
#---------------------------------------------

# classic vpn

## gateways

module "vpn_gw_spoke2_a" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id
  prefix       = var.spoke2.prefix
  network      = local.spoke2.network.self_link
  region       = var.spoke2.region_a
  gateway_name = "vpn-a"
}

module "vpn_gw_spoke2_b" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id
  prefix       = var.spoke2.prefix
  network      = local.spoke2.network.self_link
  region       = var.spoke2.region_b
  gateway_name = "vpn-b"
}
