
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

data "terraform_remote_state" "vpc1" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

locals {
  vpc1 = data.terraform_remote_state.vpc1.outputs.network.vpc1
  subnet = {
    asia = {
      browse   = data.terraform_remote_state.vpc1.outputs.subnetwork.asia.browse
      cart     = data.terraform_remote_state.vpc1.outputs.subnetwork.asia.cart
      checkout = data.terraform_remote_state.vpc1.outputs.subnetwork.asia.checkout
      db       = data.terraform_remote_state.vpc1.outputs.subnetwork.asia.db
    }
    eu = {
      browse   = data.terraform_remote_state.vpc1.outputs.subnetwork.eu.browse
      cart     = data.terraform_remote_state.vpc1.outputs.subnetwork.eu.cart
      checkout = data.terraform_remote_state.vpc1.outputs.subnetwork.eu.checkout
      db       = data.terraform_remote_state.vpc1.outputs.subnetwork.eu.db
      nic      = data.terraform_remote_state.vpc1.outputs.subnetwork.eu.nic
      batch    = data.terraform_remote_state.vpc1.outputs.subnetwork.eu.batch
    }
    us = {
      browse   = data.terraform_remote_state.vpc1.outputs.subnetwork.us.browse
      cart     = data.terraform_remote_state.vpc1.outputs.subnetwork.us.cart
      checkout = data.terraform_remote_state.vpc1.outputs.subnetwork.us.checkout
      db       = data.terraform_remote_state.vpc1.outputs.subnetwork.us.db
      mqtt     = data.terraform_remote_state.vpc1.outputs.subnetwork.us.mqtt
      nic      = data.terraform_remote_state.vpc1.outputs.subnetwork.us.nic
      probe    = data.terraform_remote_state.vpc1.outputs.subnetwork.us.probe
      payment  = data.terraform_remote_state.vpc1.outputs.subnetwork.us.payment
    }
  }
}
