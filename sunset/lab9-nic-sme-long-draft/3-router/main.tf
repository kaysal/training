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
  hub = {
    network     = data.terraform_remote_state.vpc.outputs.networks.hub.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.hub.us_subnet
  }
  spoke1 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.spoke1.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.us_subnet
  }
  spoke2 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.spoke2.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.asia_subnet
  }
}

# hub
#---------------------------------------------

# cloud router

resource "google_compute_router" "hub_router" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}router"
  network = local.hub.network.self_link
  region  = var.hub.eu.region
  bgp {
    asn               = var.hub.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges { range = local.spoke2.eu_subnet.ip_cidr_range }
    advertised_ip_ranges { range = local.spoke2.asia_subnet.ip_cidr_range }
  }
}

# spoke1
#---------------------------------------------

# cloud router

resource "google_compute_router" "spoke1_router_eu" {
  project = var.project_id_spoke1
  name    = "${var.spoke1.prefix}router"
  network = local.spoke1.network.self_link
  region  = var.spoke1.eu.region
  bgp {
    asn            = var.spoke1.asn
    advertise_mode = "CUSTOM"
    advertised_ip_ranges { range = local.spoke1.eu_subnet.ip_cidr_range }
    advertised_ip_ranges { range = local.spoke1.asia_subnet.ip_cidr_range }
    advertised_ip_ranges { range = local.spoke1.us_subnet.ip_cidr_range }
  }
}
