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
  cloud = {
    network = data.terraform_remote_state.vpc.outputs.networks.cloud.self_link
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

# cloud
#---------------------------------------------

# cloud router

resource "google_compute_router" "cloud_router" {
  name    = "${var.cloud.prefix}router"
  network = local.cloud.network
  region  = var.cloud.region

  bgp {
    asn               = var.cloud.asn
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
  }
}

# cloud nat

resource "google_compute_router_nat" "cloud_nat" {
  name                               = "${var.cloud.prefix}nat"
  router                             = google_compute_router.cloud_router.name
  region                             = var.cloud.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
