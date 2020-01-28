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

locals {
  onprem = {
    network = data.terraform_remote_state.vpc.outputs.networks.onprem.self_link
  }
  untrust = {
    network = data.terraform_remote_state.vpc.outputs.networks.untrust.self_link
  }
}

# onprem
#---------------------------------------------

# cloud router

resource "google_compute_router" "onprem_router" {
  name    = "${var.onprem.prefix}router"
  network = local.onprem.network
  region  = var.onprem.region

  bgp {
    asn               = var.onprem.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# untrust
#---------------------------------------------

# cloud router

resource "google_compute_router" "untrust_router" {
  name    = "${var.untrust.prefix}router"
  network = local.untrust.network
  region  = var.untrust.region

  bgp {
    asn               = var.untrust.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}
