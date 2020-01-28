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
  cloud1 = {
    network = data.terraform_remote_state.vpc.outputs.networks.cloud1.self_link
  }
}

# onprem
#---------------------------------------------

# cloud1 router

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

# cloud1
#---------------------------------------------

# cloud router

resource "google_compute_router" "cloud1_router" {
  name    = "${var.cloud1.prefix}router"
  network = local.cloud1.network
  region  = var.cloud1.region

  bgp {
    asn               = var.cloud1.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]

    # cloud2 subnet
    advertised_ip_ranges {
      range = "10.10.2.0/24"
    }

    # cloud3 subnet
    advertised_ip_ranges {
      range = "10.10.3.0/24"
    }

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
  name                               = "${var.cloud1.prefix}nat"
  router                             = google_compute_router.cloud1_router.name
  region                             = var.cloud1.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
