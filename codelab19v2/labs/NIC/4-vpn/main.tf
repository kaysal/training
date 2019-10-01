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

locals {
  hub = {
    network = data.terraform_remote_state.vpc.outputs.networks.hub.network
    router  = data.terraform_remote_state.router.outputs.routers.hub
  }
  spoke1 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke1.network
    router  = data.terraform_remote_state.router.outputs.routers.spoke1
  }
}

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# hub
#---------------------------------------------

# ha vpn gateway

resource "google_compute_ha_vpn_gateway" "hub_ha_vpn" {
  provider = "google-beta"
  project  = var.project_id_hub
  region   = var.hub.region_eu
  name     = "${var.hub.prefix}ha-vpn"
  network  = local.hub.network.self_link
}

# vpn tunnels

module "vpn_hub_to_spoke1" {
  source           = "../../../modules/vpn-gcp"
  project_id       = var.project_id_hub
  network          = local.hub.network.self_link
  region           = var.hub.region_eu
  vpn_gateway      = google_compute_ha_vpn_gateway.hub_ha_vpn.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.spoke1_ha_vpn.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.hub.router.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.hub.prefix}to-spoke1"
      peer_asn                  = var.spoke1.asn
      cr_bgp_session_range      = "${var.hub.router_vti1}/30"
      remote_bgp_session_ip     = var.spoke1.router_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.hub.prefix}to-spoke1"
      peer_asn                  = var.spoke1.asn
      cr_bgp_session_range      = "${var.hub.router_vti2}/30"
      remote_bgp_session_ip     = var.spoke1.router_vti2
      advertised_route_priority = 200
    },
  ]
}

# spoke1
#---------------------------------------------

# ha vpn gateway

resource "google_compute_ha_vpn_gateway" "spoke1_ha_vpn" {
  provider = "google-beta"
  project  = var.project_id_spoke1
  region   = var.spoke1.region_eu
  name     = "${var.spoke1.prefix}ha-vpn"
  network  = local.spoke1.network.self_link
}

# vpn tunnels

module "vpn_spoke1_to_hub" {
  source           = "../../../modules/vpn-gcp"
  project_id       = var.project_id_spoke1
  network          = local.spoke1.network.self_link
  region           = var.spoke1.region_eu
  vpn_gateway      = google_compute_ha_vpn_gateway.spoke1_ha_vpn.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.hub_ha_vpn.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.spoke1.router.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.spoke1.prefix}to-hub"
      peer_asn                  = var.hub.asn
      cr_bgp_session_range      = "${var.spoke1.router_vti1}/30"
      remote_bgp_session_ip     = var.hub.router_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.spoke1.prefix}to-hub"
      peer_asn                  = var.hub.asn
      cr_bgp_session_range      = "${var.spoke1.router_vti2}/30"
      remote_bgp_session_ip     = var.hub.router_vti2
      advertised_route_priority = 200
    },
  ]
}
