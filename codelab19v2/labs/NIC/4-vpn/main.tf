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
  vpc1 = {
    network = data.terraform_remote_state.vpc.outputs.networks.vpc1.network
    router  = data.terraform_remote_state.router.outputs.routers.vpc1
  }
  vpc2 = {
    network = data.terraform_remote_state.vpc.outputs.networks.vpc2.network
    router  = data.terraform_remote_state.router.outputs.routers.vpc2
  }
}

resource "random_id" "ipsec_secret" {
  byte_length = 8
}


# vpc1
#---------------------------------------------

# ha vpn gateway

resource "google_compute_ha_vpn_gateway" "vpc1_ha_vpn" {
  provider = "google-beta"
  project  = var.project_id_vpc1
  region   = var.vpc1.eu.region
  name     = "${var.vpc1.prefix}ha-vpn"
  network  = local.vpc1.network.self_link
}

# vpn tunnels

module "vpn_vpc1_to_vpc2" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id_vpc1
  network          = local.vpc1.network.self_link
  region           = var.vpc1.eu.region
  vpn_gateway      = google_compute_ha_vpn_gateway.vpc1_ha_vpn.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.vpc2_ha_vpn.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.vpc1.router.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.vpc1.prefix}to-vpc2"
      peer_asn                  = var.vpc2.asn
      cr_bgp_session_range      = "${var.vpc1.eu.cr_vti1}/30"
      remote_bgp_session_ip     = var.vpc2.eu.cr_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.vpc1.prefix}to-vpc2"
      peer_asn                  = var.vpc2.asn
      cr_bgp_session_range      = "${var.vpc1.eu.cr_vti2}/30"
      remote_bgp_session_ip     = var.vpc2.eu.cr_vti2
      advertised_route_priority = 100
    },
  ]
}

# vpc2
#---------------------------------------------

# ha vpn gateway

resource "google_compute_ha_vpn_gateway" "vpc2_ha_vpn" {
  provider = "google-beta"
  project  = var.project_id_vpc2
  region   = var.vpc2.eu.region
  name     = "${var.vpc2.prefix}ha-vpn"
  network  = local.vpc2.network.self_link
}

# vpn tunnels

module "vpn_vpc2_to_vpc1" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id_vpc2
  network          = local.vpc2.network.self_link
  region           = var.vpc2.eu.region
  vpn_gateway      = google_compute_ha_vpn_gateway.vpc2_ha_vpn.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.vpc1_ha_vpn.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.vpc2.router.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.vpc2.prefix}to-vpc1"
      peer_asn                  = var.vpc1.asn
      cr_bgp_session_range      = "${var.vpc2.eu.cr_vti1}/30"
      remote_bgp_session_ip     = var.vpc1.eu.cr_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.vpc2.prefix}to-vpc1"
      peer_asn                  = var.vpc1.asn
      cr_bgp_session_range      = "${var.vpc2.eu.cr_vti2}/30"
      remote_bgp_session_ip     = var.vpc1.eu.cr_vti2
      advertised_route_priority = 100
    },
  ]
}
