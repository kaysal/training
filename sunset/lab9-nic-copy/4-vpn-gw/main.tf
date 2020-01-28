provider "google" {}

provider "google-beta" {}

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
  onprem = {
    network = data.terraform_remote_state.vpc.outputs.networks.onprem.network
  }
  hub = {
    network = data.terraform_remote_state.vpc.outputs.networks.hub.network
  }
  spoke1 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke1.network
  }
  spoke2 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke2.network
  }
}

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# onprem
#---------------------------------------------

# vpn gateways

## ha vpn gateway

resource "google_compute_ha_vpn_gateway" "onprem_ha_vpn" {
  provider = "google-beta"
  project  = var.project_id_onprem
  region   = var.onprem.region
  name     = "${var.onprem.prefix}ha-vpn"
  network  = local.onprem.network.self_link
}

# hub
#---------------------------------------------

# ha vpn

## gateways

resource "google_compute_ha_vpn_gateway" "hub_ha_vpn" {
  provider = "google-beta"
  project  = var.project_id_hub
  region   = var.hub.region_a
  name     = "${var.hub.prefix}ha-vpn"
  network  = local.hub.network.self_link
}

# classic vpn

## gateways

module "vpn_gw_hub" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_hub
  prefix       = var.hub.prefix
  network      = local.hub.network.self_link
  region       = var.hub.region_a
  gateway_name = "vpn"
}

# spoke1
#---------------------------------------------

# classic vpn

## gateways

module "vpn_gw_spoke1" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_spoke1
  prefix       = var.spoke1.prefix
  network      = local.spoke1.network.self_link
  region       = var.spoke1.region
  gateway_name = "vpn"
}
