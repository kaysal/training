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
    network  = data.terraform_remote_state.vpc.outputs.networks.onprem
    subnet_a = data.terraform_remote_state.vpc.outputs.cidrs.onprem_a
    subnet_b = data.terraform_remote_state.vpc.outputs.cidrs.onprem_b
  }
  hub = {
    network = data.terraform_remote_state.vpc.outputs.networks.hub
  }
  spoke1 = {
    network  = data.terraform_remote_state.vpc.outputs.networks.spoke1
    subnet_a = data.terraform_remote_state.vpc.outputs.cidrs.spoke1_a
    subnet_b = data.terraform_remote_state.vpc.outputs.cidrs.spoke1_b
  }
  spoke2 = {
    network  = data.terraform_remote_state.vpc.outputs.networks.spoke2
    subnet_a = data.terraform_remote_state.vpc.outputs.cidrs.spoke2_a
    subnet_b = data.terraform_remote_state.vpc.outputs.cidrs.spoke2_b
  }
}

# onprem
#---------------------------------------------

# cloud router

resource "google_compute_router" "onprem_router_a" {
  name    = "${var.onprem.prefix}router-a"
  network = local.onprem.network.self_link
  region  = var.onprem.region_a

  bgp {
    asn               = var.onprem.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_router" "onprem_router_b" {
  name    = "${var.onprem.prefix}router-b"
  network = local.onprem.network.self_link
  region  = var.onprem.region_b

  bgp {
    asn               = var.onprem.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# hub
#---------------------------------------------

# cloud router

resource "google_compute_router" "hub_router_a" {
  name    = "${var.hub.prefix}router-a"
  network = local.hub.network.self_link
  region  = var.hub.region_a

  bgp {
    asn               = var.hub.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

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
      range = "10.1.1.0/24"
    }

    # spoke2 prefixes
    advertised_ip_ranges {
      range = "10.2.1.0/24"
    }
  }
}

resource "google_compute_router" "hub_router_b" {
  name    = "${var.hub.prefix}router-b"
  network = local.hub.network.self_link
  region  = var.hub.region_b

  bgp {
    asn               = var.hub.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

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
      range = "10.1.2.0/24"
    }

    # spoke2 prefixes
    advertised_ip_ranges {
      range = "10.2.2.0/24"
    }
  }
}
