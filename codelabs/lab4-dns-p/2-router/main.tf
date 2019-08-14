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

  cloud1 = {
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud1.network.self_link
  }
}

# onprem
#---------------------------------------------

# cloud1 router

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

# cloud1
#---------------------------------------------

# cloud router

resource "google_compute_router" "cloud1_router" {
  name    = "${var.cloud1.prefix}router"
  network = local.cloud1.network_self_link
  region  = var.cloud1.region

  bgp {
    asn               = var.cloud1.asn
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

resource "google_compute_router_nat" "cloud_nat" {
  name                               = "${var.cloud1.prefix}nat"
  router                             = google_compute_router.cloud1_router.name
  region                             = var.cloud1.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
