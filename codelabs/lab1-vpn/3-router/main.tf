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
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.onprem.network.self_link
  }

  cloud = {
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud.network.self_link
  }
}

# onprem
#---------------------------------------------

# cloud router

resource "google_compute_router" "onprem_router" {
  name    = "${var.onprem.prefix}router"
  network = local.onprem.network_self_link
  region  = var.onprem.region

  bgp {
    asn               = var.onprem.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# cloud
#---------------------------------------------

# cloud router

resource "google_compute_router" "cloud_router" {
  name    = "${var.cloud.prefix}router"
  network = local.cloud.network_self_link
  region  = var.cloud.region

  bgp {
    asn               = var.cloud.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}
