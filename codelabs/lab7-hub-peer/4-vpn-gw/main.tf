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
  project  = var.project_id_onprem
  region   = var.onprem.region_a
  name     = "${var.onprem.prefix}ha-vpn-a"
  network  = local.onprem.network.self_link
}

resource "google_compute_ha_vpn_gateway" "onprem_ha_vpn_b" {
  provider = "google-beta"
  project  = var.project_id_onprem
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
  project  = var.project_id_hub
  region   = var.hub.region_a
  name     = "${var.hub.prefix}ha-vpn-a"
  network  = local.hub.network.self_link
}

resource "google_compute_ha_vpn_gateway" "hub_ha_vpn_b" {
  provider = "google-beta"
  project  = var.project_id_hub
  region   = var.hub.region_b
  name     = "${var.hub.prefix}ha-vpn-b"
  network  = local.hub.network.self_link
}
