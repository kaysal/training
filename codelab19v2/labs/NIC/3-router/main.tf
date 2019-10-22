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
  vpc1 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.vpc1.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.vpc1.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.vpc1.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.vpc1.us_subnet
  }
  vpc2 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.vpc2.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.vpc2.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.vpc2.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.vpc2.us_subnet
  }
}

# vpc1
#---------------------------------------------

# cloud router

resource "google_compute_router" "vpc1_router_eu" {
  project = var.project_id_vpc1
  name    = "${var.vpc1.prefix}router"
  network = local.vpc1.network.self_link
  region  = var.vpc1.eu.region
  bgp {
    asn            = var.vpc1.asn
    advertise_mode = "CUSTOM"
    advertised_ip_ranges { range = local.vpc1.eu_subnet.ip_cidr_range }
    advertised_ip_ranges { range = local.vpc1.asia_subnet.ip_cidr_range }
    #advertised_ip_ranges { range = local.vpc1.us_subnet.ip_cidr_range }
  }
}

# vpc2
#---------------------------------------------

# cloud router

resource "google_compute_router" "vpc2_router" {
  project = var.project_id_vpc2
  name    = "${var.vpc2.prefix}router"
  network = local.vpc2.network.self_link
  region  = var.vpc2.eu.region
  bgp {
    asn               = var.vpc2.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}
