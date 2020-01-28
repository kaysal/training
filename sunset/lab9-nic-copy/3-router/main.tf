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
  onprem = {
    network = data.terraform_remote_state.vpc.outputs.networks.onprem.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet2
    subnet3 = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet3
  }
  hub = {
    network = data.terraform_remote_state.vpc.outputs.networks.hub.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet2
  }
  spoke1 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke1.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet2
  }
  spoke2 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke2.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet2
  }
}

# onprem
#---------------------------------------------

# cloud router

resource "google_compute_router" "onprem_router" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}router"
  network = local.onprem.network.self_link
  region  = var.onprem.region

  bgp {
    asn            = var.onprem.asn
    advertise_mode = "CUSTOM"

    # subnet1
    advertised_ip_ranges {
      range = local.onprem.subnet1.ip_cidr_range
    }
    /*
    # subnet2
    advertised_ip_ranges {
      range = local.onprem.subnet2.ip_cidr_range
    }
*/
    # subnet3
    advertised_ip_ranges {
      range = local.onprem.subnet3.ip_cidr_range
    }
  }
}

# hub
#---------------------------------------------

# cloud router

resource "google_compute_router" "hub_router" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}router"
  network = local.hub.network.self_link
  region  = var.hub.region_a

  bgp {
    asn            = var.hub.asn
    advertise_mode = "CUSTOM"

    # restricted.googleapis.com
    advertised_ip_ranges {
      range = "199.36.153.4/30"
    }

    # private.googleapis.com
    advertised_ip_ranges {
      range = "199.36.153.8/30"
    }

    # spoke1 prefixes
    advertised_ip_ranges {
      range = "10.0.0.0/8"
    }
  }
}
