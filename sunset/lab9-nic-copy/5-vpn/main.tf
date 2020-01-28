provider "google" {}

provider "google-beta" {}

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
    network = data.terraform_remote_state.vpc.outputs.networks.onprem.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet2
    subnet3 = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet3
    router  = data.terraform_remote_state.router.outputs.routers.onprem
    ha_vpn  = data.terraform_remote_state.gateway.outputs.gateway.onprem.ha_vpn
  }
  hub = {
    network = data.terraform_remote_state.vpc.outputs.networks.hub.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet2
    router  = data.terraform_remote_state.router.outputs.routers.hub
    ha_vpn  = data.terraform_remote_state.gateway.outputs.gateway.hub.ha_vpn
    vpn     = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn
    vpn_ip  = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_ip
  }
  spoke1 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke1.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet2
    vpn     = data.terraform_remote_state.gateway.outputs.gateway.spoke1.vpn
    vpn_ip  = data.terraform_remote_state.gateway.outputs.gateway.spoke1.vpn_ip
  }
  spoke2 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke2.network
  }
}

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# onprem
#---------------------------------------------

# vpn tunnels

## ha vpn tunnels

module "vpn_onprem_to_hub" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id_onprem
  network          = local.onprem.network.self_link
  region           = var.onprem.region
  vpn_gateway      = local.onprem.ha_vpn.self_link
  peer_gcp_gateway = local.hub.ha_vpn.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.onprem.router.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.onprem.prefix}to-hub"
      peer_asn                  = var.hub.asn
      cr_bgp_session_range      = "${var.onprem.router_vti1}/30"
      remote_bgp_session_ip     = var.hub.router_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.onprem.prefix}to-hub"
      peer_asn                  = var.hub.asn
      cr_bgp_session_range      = "${var.onprem.router_vti2}/30"
      remote_bgp_session_ip     = var.hub.router_vti2
      advertised_route_priority = 200
    },
  ]
}

# hub
#---------------------------------------------

# ha vpn

## tunnel to onprem location a

module "vpn_hub_to_onprem" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id_hub
  network          = local.hub.network.self_link
  region           = var.hub.region_a
  vpn_gateway      = local.hub.ha_vpn.self_link
  peer_gcp_gateway = local.onprem.ha_vpn.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.hub.router.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.hub.prefix}to-onprem"
      peer_asn                  = var.onprem.asn
      cr_bgp_session_range      = "${var.hub.router_vti1}/30"
      remote_bgp_session_ip     = var.onprem.router_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.hub.prefix}to-onprem"
      peer_asn                  = var.onprem.asn
      cr_bgp_session_range      = "${var.hub.router_vti2}/30"
      remote_bgp_session_ip     = var.onprem.router_vti2
      advertised_route_priority = 200
    },
  ]
}

# classic vpn

## tunnel to spoke1

module "vpn_hub_to_spoke1" {
  source                = "../../modules/vpn"
  project_id            = var.project_id_hub
  network               = local.hub.network.self_link
  region                = var.hub.region_a
  gateway               = local.hub.vpn.self_link
  tunnel_name           = "${var.hub.prefix}to-spoke1"
  shared_secret         = random_id.ipsec_secret.b64_url
  peer_ip               = local.spoke1.vpn_ip.address
  static_route_priority = 100
  remote_ip_cidr_ranges = [
    local.spoke1.subnet1.ip_cidr_range,
    local.spoke1.subnet2.ip_cidr_range,
  ]
}

# spoke1
#---------------------------------------------

# classic vpn

## tunnel to hub region a

module "vpn_spoke1_to_hub" {
  source                = "../../modules/vpn"
  project_id            = var.project_id_spoke1
  network               = local.spoke1.network.self_link
  region                = var.spoke1.region
  gateway               = local.spoke1.vpn.self_link
  tunnel_name           = "${var.spoke1.prefix}to-hub"
  shared_secret         = random_id.ipsec_secret.b64_url
  peer_ip               = local.hub.vpn_ip.address
  static_route_priority = 100
  remote_ip_cidr_ranges = [
    "172.16.0.0/16",
    "10.0.0.0/8"
  ]
}
