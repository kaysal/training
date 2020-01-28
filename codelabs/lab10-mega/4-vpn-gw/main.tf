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
    vpc = data.terraform_remote_state.vpc.outputs.networks.onprem
  }
  hub = {
    vpc_eu1    = data.terraform_remote_state.vpc.outputs.networks.hub.eu1
    vpc_eu1x   = data.terraform_remote_state.vpc.outputs.networks.hub.eu1x
    vpc_eu2    = data.terraform_remote_state.vpc.outputs.networks.hub.eu2
    vpc_eu2x   = data.terraform_remote_state.vpc.outputs.networks.hub.eu2x
    vpc_asia1  = data.terraform_remote_state.vpc.outputs.networks.hub.asia1
    vpc_asia1x = data.terraform_remote_state.vpc.outputs.networks.hub.asia1x
    vpc_asia2  = data.terraform_remote_state.vpc.outputs.networks.hub.asia2
    vpc_asia2x = data.terraform_remote_state.vpc.outputs.networks.hub.asia2x
    vpc_us1    = data.terraform_remote_state.vpc.outputs.networks.hub.us1
    vpc_us1x   = data.terraform_remote_state.vpc.outputs.networks.hub.us1x
    vpc_us2    = data.terraform_remote_state.vpc.outputs.networks.hub.us2
    vpc_us2x   = data.terraform_remote_state.vpc.outputs.networks.hub.us2x
  }
}

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# onprem
#---------------------------------------------

## gateways

module "vpn_gw_onprem_eu" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_onprem
  prefix       = "${var.onprem.prefix}"
  network      = local.onprem.vpc.self_link
  region       = var.onprem.eu.region
  gateway_name = "vpn-eu"
}

module "vpn_gw_onprem_asia" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_onprem
  prefix       = "${var.onprem.prefix}"
  network      = local.onprem.vpc.self_link
  region       = var.onprem.asia.region
  gateway_name = "vpn-asia"
}

module "vpn_gw_onprem_us" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_onprem
  prefix       = "${var.onprem.prefix}"
  network      = local.onprem.vpc.self_link
  region       = var.onprem.us.region
  gateway_name = "vpn-us"
}

# hub
#---------------------------------------------

# eu gateways

module "vpn_gw_hub_eu1" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_hub
  prefix       = "${var.hub.prefix}"
  network      = local.hub.vpc_eu1.self_link
  region       = var.hub.eu1.region
  gateway_name = "vpn-eu1"
}

module "vpn_gw_hub_eu2" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_hub
  prefix       = "${var.hub.prefix}"
  network      = local.hub.vpc_eu2.self_link
  region       = var.hub.eu2.region
  gateway_name = "vpn-eu2"
}

# asia gateways

module "vpn_gw_hub_asia1" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_hub
  prefix       = "${var.hub.prefix}"
  network      = local.hub.vpc_asia1.self_link
  region       = var.hub.asia1.region
  gateway_name = "vpn-asia1"
}

module "vpn_gw_hub_asia2" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_hub
  prefix       = "${var.hub.prefix}"
  network      = local.hub.vpc_asia2.self_link
  region       = var.hub.asia2.region
  gateway_name = "vpn-asia2"
}

# us gateways

module "vpn_gw_hub_us1" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_hub
  prefix       = "${var.hub.prefix}"
  network      = local.hub.vpc_us1.self_link
  region       = var.hub.us1.region
  gateway_name = "vpn-us1"
}

module "vpn_gw_hub_us2" {
  source       = "../../modules/vpn-gw"
  project_id   = var.project_id_hub
  prefix       = "${var.hub.prefix}"
  network      = local.hub.vpc_us2.self_link
  region       = var.hub.us2.region
  gateway_name = "vpn-us2"
}
