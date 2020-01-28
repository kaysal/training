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
    network  = data.terraform_remote_state.vpc.outputs.vpc.onprem.network
  }
  hub = {
    network = data.terraform_remote_state.vpc.outputs.vpc.hub.network
  }
  spoke1 = {
    network  = data.terraform_remote_state.vpc.outputs.vpc.spoke1.network
  }
  spoke2 = {
    network  = data.terraform_remote_state.vpc.outputs.vpc.spoke2.network
  }
}

# onprem
#---------------------------------------------

# cloud router

resource "google_compute_router" "onprem_belgium_router" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}belgium-router"
  network = local.onprem.network.self_link
  region  = var.onprem.belgium.region

  bgp {
    asn               = var.onprem.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_router" "onprem_london_router" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}london-router"
  network = local.onprem.network.self_link
  region  = var.onprem.london.region

  bgp {
    asn               = var.onprem.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# hub
#---------------------------------------------

# cloud router

resource "google_compute_router" "hub_belgium_router" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}belgium-router"
  network = local.hub.network.self_link
  region  = var.hub.belgium.region

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

resource "google_compute_router" "hub_london_router" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}london-router"
  network = local.hub.network.self_link
  region  = var.hub.london.region

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
