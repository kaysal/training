# provider

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# data

data "terraform_remote_state" "vpc_data" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

locals {
  vpc    = data.terraform_remote_state.vpc_data.outputs.network.vpc
  subnet = data.terraform_remote_state.vpc_data.outputs.network.subnet
}

# local variables

locals {
  ic_zone1_url = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/interconnects/${var.ic_zone1}"
  ic_zone2_url = "https://www.googleapis.com/compute/v1/projects/${var.project_id}/global/interconnects/${var.ic_zone2}"
}

# zone1 interconnect attachment

resource "google_compute_router" "prod_router1" {
  name    = "${var.prefix}prod-router1"
  network = local.vpc.self_link
  region  = "europe-west2"
  bgp {
    asn            = "65500"
    advertise_mode = "CUSTOM"
    advertised_ip_ranges {
      range = local.subnet.ip_cidr_range
    }
  }
}

resource "google_compute_interconnect_attachment" "prod_ic3_vlan_100" {
  name              = "${var.prefix}prod-ic3-vlan-100"
  interconnect      = local.ic_zone1_url
  type              = "DEDICATED"
  region            = "europe-west2"
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = 100
  router            = "${google_compute_router.prod_router1.self_link}"
  candidate_subnets = ["169.254.30.0/29"]
  admin_enabled     = true
}

# zone2 interconnect attachment

resource "google_compute_router" "prod_router2" {
  name    = "${var.prefix}prod-router2"
  network = local.vpc.self_link
  region  = "europe-west2"
  bgp {
    asn            = "65500"
    advertise_mode = "CUSTOM"
    advertised_ip_ranges {
      range = local.subnet.ip_cidr_range
    }
  }
}

resource "google_compute_interconnect_attachment" "prod_ic4_vlan_100" {
  name              = "${var.prefix}prod-ic4-vlan-100"
  interconnect      = local.ic_zone2_url
  type              = "DEDICATED"
  bandwidth         = "BPS_10G"
  vlan_tag8021q     = 100
  region            = "europe-west2"
  router            = "${google_compute_router.prod_router2.self_link}"
  candidate_subnets = ["169.254.40.0/29"]
  admin_enabled     = true
}
