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

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# onprem
#---------------------------------------------

# vpn tunnels

## ha vpn tunnels

module "vpn_onprem_a_to_hub_a" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id_onprem
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
  project_id       = var.project_id_onprem
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
  project_id       = var.project_id_hub
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
  project_id       = var.project_id_hub
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
