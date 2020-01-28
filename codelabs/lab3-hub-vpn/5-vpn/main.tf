provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

provider "random" {}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "router" {
  backend = "local"

  config = {
    path = "../3-router/terraform.tfstate"
  }
}

data "terraform_remote_state" "gateway" {
  backend = "local"

  config = {
    path = "../4-vpn-gw/terraform.tfstate"
  }
}

locals {
  onprem = {
    network  = data.terraform_remote_state.vpc.outputs.networks.onprem
    subnet_a = data.terraform_remote_state.vpc.outputs.cidrs.onprem_a
    subnet_b = data.terraform_remote_state.vpc.outputs.cidrs.onprem_b
    router_a = data.terraform_remote_state.router.outputs.routers.onprem_a
    router_b = data.terraform_remote_state.router.outputs.routers.onprem_b
    ha_vpn_a = data.terraform_remote_state.gateway.outputs.gateway.onprem.ha_vpn_a
    ha_vpn_b = data.terraform_remote_state.gateway.outputs.gateway.onprem.ha_vpn_b
  }
  hub = {
    network  = data.terraform_remote_state.vpc.outputs.networks.hub
    router_a = data.terraform_remote_state.router.outputs.routers.hub_a
    router_b = data.terraform_remote_state.router.outputs.routers.hub_b
    ha_vpn_a = data.terraform_remote_state.gateway.outputs.gateway.hub.ha_vpn_a
    ha_vpn_b = data.terraform_remote_state.gateway.outputs.gateway.hub.ha_vpn_b
    vpn_a    = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_a
    vpn_b    = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_b
    vpn_a_ip = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_a_ip
    vpn_b_ip = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_b_ip
  }
  spoke1 = {
    network  = data.terraform_remote_state.vpc.outputs.networks.spoke1
    subnet_a = data.terraform_remote_state.vpc.outputs.cidrs.spoke1_a
    subnet_b = data.terraform_remote_state.vpc.outputs.cidrs.spoke1_b
    vpn_a    = data.terraform_remote_state.gateway.outputs.gateway.spoke1.vpn_a
    vpn_b    = data.terraform_remote_state.gateway.outputs.gateway.spoke1.vpn_b
    vpn_a_ip = data.terraform_remote_state.gateway.outputs.gateway.spoke1.vpn_a_ip
    vpn_b_ip = data.terraform_remote_state.gateway.outputs.gateway.spoke1.vpn_b_ip
  }
  spoke2 = {
    network  = data.terraform_remote_state.vpc.outputs.networks.spoke2
    subnet_a = data.terraform_remote_state.vpc.outputs.cidrs.spoke2_a
    subnet_b = data.terraform_remote_state.vpc.outputs.cidrs.spoke2_b
    vpn_a    = data.terraform_remote_state.gateway.outputs.gateway.spoke2.vpn_a
    vpn_b    = data.terraform_remote_state.gateway.outputs.gateway.spoke2.vpn_b
    vpn_a_ip = data.terraform_remote_state.gateway.outputs.gateway.spoke2.vpn_a_ip
    vpn_b_ip = data.terraform_remote_state.gateway.outputs.gateway.spoke2.vpn_b_ip
  }
}

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# onprem
#---------------------------------------------

# vpn tunnels

## ha vpn tunnels

module "vpn_onprem_a_to_hub_a" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = local.onprem.network.self_link
  region           = var.onprem.region_a
  vpn_gateway      = local.onprem.ha_vpn_a.self_link
  peer_gcp_gateway = local.hub.ha_vpn_a.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.onprem.router_a.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.onprem.prefix}to-hub-a"
      peer_asn                  = var.hub.asn
      cr_bgp_session_range      = "${var.onprem.router_a_vti1}/30"
      remote_bgp_session_ip     = var.hub.router_a_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.onprem.prefix}to-hub-a"
      peer_asn                  = var.hub.asn
      cr_bgp_session_range      = "${var.onprem.router_a_vti2}/30"
      remote_bgp_session_ip     = var.hub.router_a_vti2
      advertised_route_priority = 200
    },
  ]
}

module "vpn_onprem_b_to_hub_b" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = local.onprem.network.self_link
  region           = var.onprem.region_b
  vpn_gateway      = local.onprem.ha_vpn_b.self_link
  peer_gcp_gateway = local.hub.ha_vpn_b.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.onprem.router_b.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.onprem.prefix}to-hub-b"
      peer_asn                  = var.hub.asn
      cr_bgp_session_range      = "${var.onprem.router_b_vti1}/30"
      remote_bgp_session_ip     = var.hub.router_b_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.onprem.prefix}to-hub-b"
      peer_asn                  = var.hub.asn
      cr_bgp_session_range      = "${var.onprem.router_b_vti2}/30"
      remote_bgp_session_ip     = var.hub.router_b_vti2
      advertised_route_priority = 200
    },
  ]
}

# hub
#---------------------------------------------

# ha vpn

## tunnel to onprem location a

module "vpn_hub_a_to_onprem_a" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = local.hub.network.self_link
  region           = var.hub.region_a
  vpn_gateway      = local.hub.ha_vpn_a.self_link
  peer_gcp_gateway = local.onprem.ha_vpn_a.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.hub.router_a.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.hub.prefix}to-onprem-a"
      peer_asn                  = var.onprem.asn
      cr_bgp_session_range      = "${var.hub.router_a_vti1}/30"
      remote_bgp_session_ip     = var.onprem.router_a_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.hub.prefix}to-onprem-a"
      peer_asn                  = var.onprem.asn
      cr_bgp_session_range      = "${var.hub.router_a_vti2}/30"
      remote_bgp_session_ip     = var.onprem.router_a_vti2
      advertised_route_priority = 200
    },
  ]
}

## tunnel to onprem location b

module "vpn_hub_b_to_onprem_b" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = local.hub.network.self_link
  region           = var.hub.region_b
  vpn_gateway      = local.hub.ha_vpn_b.self_link
  peer_gcp_gateway = local.onprem.ha_vpn_b.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.hub.router_b.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.hub.prefix}to-onprem-b"
      peer_asn                  = var.onprem.asn
      cr_bgp_session_range      = "${var.hub.router_b_vti1}/30"
      remote_bgp_session_ip     = var.onprem.router_b_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.hub.prefix}to-onprem-b"
      peer_asn                  = var.onprem.asn
      cr_bgp_session_range      = "${var.hub.router_b_vti2}/30"
      remote_bgp_session_ip     = var.onprem.router_b_vti2
      advertised_route_priority = 200
    },
  ]
}

# classic vpn

## tunnel to spoke1

module "vpn_hub_a_to_spoke1_a" {
  source                = "../../modules/vpn"
  project_id            = var.project_id
  network               = local.hub.network.self_link
  region                = var.hub.region_a
  gateway               = local.hub.vpn_a.self_link
  tunnel_name           = "${var.hub.prefix}to-spoke1-a"
  shared_secret         = random_id.ipsec_secret.b64_url
  peer_ip               = local.spoke1.vpn_a_ip.address
  static_route_priority = 100
  remote_ip_cidr_ranges = [local.spoke1.subnet_a.ip_cidr_range]
}

module "vpn_hub_b_to_spoke1_b" {
  source                = "../../modules/vpn"
  project_id            = var.project_id
  network               = local.hub.network.self_link
  region                = var.hub.region_b
  gateway               = local.hub.vpn_b.self_link
  tunnel_name           = "${var.hub.prefix}to-spoke1-b"
  shared_secret         = random_id.ipsec_secret.b64_url
  peer_ip               = local.spoke1.vpn_b_ip.address
  static_route_priority = 100
  remote_ip_cidr_ranges = [local.spoke1.subnet_b.ip_cidr_range]
}

## tunnel to spoke2
/*
module "vpn_hub_a_to_spoke2_a" {
  source                = "../../modules/vpn"
  project_id            = var.project_id
  network               = local.hub.network.self_link
  region                = var.hub.region_a
  gateway               = local.hub.vpn_a.self_link
  tunnel_name           = "${var.hub.prefix}to-spoke2-a"
  shared_secret         = random_id.ipsec_secret.b64_url
  peer_ip               = local.spoke2.vpn_a_ip.address
  static_route_priority = 100
  remote_ip_cidr_ranges = [local.spoke2.subnet_a.ip_cidr_range]
}

module "vpn_hub_b_to_spoke2_b" {
  source                = "../../modules/vpn"
  project_id            = var.project_id
  network               = local.hub.network.self_link
  region                = var.hub.region_b
  gateway               = local.hub.vpn_b.self_link
  tunnel_name           = "${var.hub.prefix}to-spoke2-b"
  shared_secret         = random_id.ipsec_secret.b64_url
  peer_ip               = local.spoke2.vpn_b_ip.address
  static_route_priority = 100
  remote_ip_cidr_ranges = [local.spoke2.subnet_b.ip_cidr_range]
}*/

# spoke1
#---------------------------------------------

# classic vpn

## tunnel to hub region a

module "vpn_spoke1_to_hub_a" {
  source                = "../../modules/vpn"
  project_id            = var.project_id
  network               = local.spoke1.network.self_link
  region                = var.spoke1.region_a
  gateway               = local.spoke1.vpn_a.self_link
  tunnel_name           = "${var.spoke1.prefix}to-hub-a"
  shared_secret         = random_id.ipsec_secret.b64_url
  peer_ip               = local.hub.vpn_a_ip.address
  static_route_priority = 100
  remote_ip_cidr_ranges = ["172.16.0.0/16", "10.0.0.0/8"]
}

## tunnel to hub region b

module "vpn_spoke1_to_hub_b" {
  source                = "../../modules/vpn"
  project_id            = var.project_id
  network               = local.spoke1.network.self_link
  region                = var.spoke1.region_b
  gateway               = local.spoke1.vpn_b.self_link
  tunnel_name           = "${var.spoke1.prefix}to-hub-b"
  shared_secret         = random_id.ipsec_secret.b64_url
  peer_ip               = local.hub.vpn_b_ip.address
  static_route_priority = 100
  remote_ip_cidr_ranges = ["172.16.0.0/16", "10.0.0.0/8"]
}

# spoke2
#---------------------------------------------

# classic vpn
/*
## tunnel to hub region a

module "vpn_spoke2_to_hub_a" {
  source                = "../../modules/vpn"
  project_id            = var.project_id
  network               = local.spoke2.network.self_link
  region                = var.spoke2.region_a
  gateway               = local.spoke2.vpn_a.self_link
  tunnel_name           = "${var.spoke2.prefix}to-hub-a"
  shared_secret         = random_id.ipsec_secret.b64_url
  peer_ip               = local.hub.vpn_a_ip.address
  static_route_priority = 100
  remote_ip_cidr_ranges = ["172.16.0.0/16", "10.0.0.0/8"]
}

## tunnel to hub region b

module "vpn_spoke2_to_hub_b" {
  source                = "../../modules/vpn"
  project_id            = var.project_id
  network               = local.spoke2.network.self_link
  region                = var.spoke2.region_b
  gateway               = local.spoke2.vpn_b.self_link
  tunnel_name           = "${var.spoke2.prefix}to-hub-b"
  shared_secret         = random_id.ipsec_secret.b64_url
  peer_ip               = local.hub.vpn_b_ip.address
  static_route_priority = 100
  remote_ip_cidr_ranges = ["172.16.0.0/16", "10.0.0.0/8"]
}*/
