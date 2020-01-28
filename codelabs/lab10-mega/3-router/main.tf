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
    vpc       = data.terraform_remote_state.vpc.outputs.networks.onprem
    eu_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.onprem.eu_cidr
    asia_cidr = data.terraform_remote_state.vpc.outputs.cidrs.onprem.asia_cidr
    us_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.onprem.us_cidr
  }
  hub = {
    vpc_eu1     = data.terraform_remote_state.vpc.outputs.networks.hub.eu1
    vpc_eu1x    = data.terraform_remote_state.vpc.outputs.networks.hub.eu1x
    vpc_eu2     = data.terraform_remote_state.vpc.outputs.networks.hub.eu2
    vpc_eu2x    = data.terraform_remote_state.vpc.outputs.networks.hub.eu2x
    vpc_asia1   = data.terraform_remote_state.vpc.outputs.networks.hub.asia1
    vpc_asia1x  = data.terraform_remote_state.vpc.outputs.networks.hub.asia1x
    vpc_asia2   = data.terraform_remote_state.vpc.outputs.networks.hub.asia2
    vpc_asia2x  = data.terraform_remote_state.vpc.outputs.networks.hub.asia2x
    vpc_us1     = data.terraform_remote_state.vpc.outputs.networks.hub.us1
    vpc_us1x    = data.terraform_remote_state.vpc.outputs.networks.hub.us1x
    vpc_us2     = data.terraform_remote_state.vpc.outputs.networks.hub.us2
    vpc_us2x    = data.terraform_remote_state.vpc.outputs.networks.hub.us2x
    eu1_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu1_cidr
    eu1_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu1_cidrx
    eu2_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu2_cidr
    eu2_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu2_cidrx
    asia1_cidr  = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia1_cidr
    asia1_cidrx = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia1_cidrx
    asia2_cidr  = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia2_cidr
    asia2_cidrx = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia2_cidrx
    us1_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.us1_cidr
    us1_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.us1_cidrx
    us2_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.us2_cidr
    us2_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.us2_cidrx
  }
}

# onprem
#---------------------------------------------

# eu router

resource "google_compute_router" "onprem_router_eu" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}router-eu"
  network = local.onprem.vpc.self_link
  region  = var.onprem.eu.region

  bgp {
    asn               = var.onprem.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# asia router

resource "google_compute_router" "onprem_router_asia" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}router-asia"
  network = local.onprem.vpc.self_link
  region  = var.onprem.asia.region

  bgp {
    asn               = var.onprem.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# us router

resource "google_compute_router" "onprem_router_us" {
  project = var.project_id_onprem
  name    = "${var.onprem.prefix}router-us"
  network = local.onprem.vpc.self_link
  region  = var.onprem.us.region

  bgp {
    asn               = var.onprem.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# hub
#---------------------------------------------

# eu routers

resource "google_compute_router" "hub_router_eu1" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}router-eu1"
  network = local.hub.vpc_eu1.self_link
  region  = var.hub.eu1.region

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
    advertised_ip_ranges {
      range = var.svc.eu1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.eu2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us2.cidr
    }
  }
}

resource "google_compute_router" "hub_router_eu2" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}router-eu2"
  network = local.hub.vpc_eu2.self_link
  region  = var.hub.eu2.region

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
    advertised_ip_ranges {
      range = var.svc.eu1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.eu2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us2.cidr
    }
  }
}

# asia routers

resource "google_compute_router" "hub_router_asia1" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}router-asia1"
  network = local.hub.vpc_asia1.self_link
  region  = var.hub.asia1.region

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
    advertised_ip_ranges {
      range = var.svc.eu1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.eu2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us2.cidr
    }
  }
}

resource "google_compute_router" "hub_router_asia2" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}router-asia2"
  network = local.hub.vpc_asia2.self_link
  region  = var.hub.asia2.region

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
    advertised_ip_ranges {
      range = var.svc.eu1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.eu2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us2.cidr
    }
  }
}

# us routers

resource "google_compute_router" "hub_router_us1" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}router-us1"
  network = local.hub.vpc_us1.self_link
  region  = var.hub.us1.region

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
    advertised_ip_ranges {
      range = var.svc.eu1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.eu2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us2.cidr
    }
  }
}

resource "google_compute_router" "hub_router_us2" {
  project = var.project_id_hub
  name    = "${var.hub.prefix}router-us2"
  network = local.hub.vpc_us2.self_link
  region  = var.hub.us2.region

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
    advertised_ip_ranges {
      range = var.svc.eu1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.eu2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.asia2.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us1.cidr
    }
    advertised_ip_ranges {
      range = var.svc.us2.cidr
    }
  }
}
