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
    subnet_eu   = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet_eu
    subnet_asia = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet_asia
    subnet_us   = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet_us
  }
  spoke1 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.spoke1.network
    subnet_eu   = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet_eu
    subnet_asia = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet_asia
    subnet_us   = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet_us
  }
  spoke2 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.spoke2.network
    subnet_eu   = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet_eu
    subnet_asia = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet_asia
    subnet_us   = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet_us
  }
}

# hub
#---------------------------------------------

# cloud router

resource "google_compute_router" "hub_router" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}router"
  network = local.hub.network.self_link
  region  = var.hub.region_eu

  bgp {
    asn            = var.hub.asn
    advertise_mode = "CUSTOM"

    advertised_ip_ranges {
      range = local.hub.subnet_eu.ip_cidr_range
    }

    advertised_ip_ranges {
      range = local.hub.subnet_us.ip_cidr_range
    }

    advertised_ip_ranges {
      range = local.hub.subnet_asia.ip_cidr_range
    }

    advertised_ip_ranges {
      range = local.spoke2.subnet_eu.ip_cidr_range
    }

    advertised_ip_ranges {
      range = local.spoke2.subnet_asia.ip_cidr_range
    }
  }
}

# spoke1
#---------------------------------------------

# cloud router

resource "google_compute_router" "spoke1_router_eu" {
  project = var.project_id_spoke1
  name    = "${var.spoke1.prefix}router-eu"
  network = local.spoke1.network.self_link
  region  = var.spoke1.region_eu

  bgp {
    asn               = var.spoke1.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}
