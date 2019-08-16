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

locals {
  onprem = {
    router  = data.terraform_remote_state.router.outputs.router.onprem.name
    network = data.terraform_remote_state.vpc.outputs.networks.onprem.self_link
  }
  cloud1 = {
    router  = data.terraform_remote_state.router.outputs.router.cloud1.name
    network = data.terraform_remote_state.vpc.outputs.networks.cloud1.self_link
  }
}

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# onprem
#---------------------------------------------

# vpn gateway

resource "google_compute_ha_vpn_gateway" "onprem_vpn_gw" {
  provider = "google-beta"
  region   = var.onprem.region
  name     = "${var.onprem.prefix}vpn-gw"
  network  = local.onprem.network
}

# vpn tunnel

module "vpn_onprem_to_cloud" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = local.onprem.network
  region           = var.onprem.region
  vpn_gateway      = google_compute_ha_vpn_gateway.onprem_vpn_gw.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.cloud1_vpn_gw.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.onprem.router
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.onprem.prefix}to-cloud"
      peer_asn                  = var.cloud1.asn
      cr_bgp_session_range      = "${var.onprem.router_vti1}/30"
      remote_bgp_session_ip     = var.cloud1.router_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.onprem.prefix}to-cloud"
      peer_asn                  = var.cloud1.asn
      cr_bgp_session_range      = "${var.onprem.router_vti2}/30"
      remote_bgp_session_ip     = var.cloud1.router_vti2
      advertised_route_priority = 100
    },
  ]
}

# cloud1
#---------------------------------------------

# vpn gateway

resource "google_compute_ha_vpn_gateway" "cloud1_vpn_gw" {
  provider = "google-beta"
  region   = var.cloud1.region
  name     = "${var.cloud1.prefix}vpn-gw"
  network  = local.cloud1.network
}

# vpn tunnel

module "vpn_cloud1_to_onprem" {
  source           = "../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = local.cloud1.network
  region           = var.cloud1.region
  vpn_gateway      = google_compute_ha_vpn_gateway.cloud1_vpn_gw.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.onprem_vpn_gw.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = local.cloud1.router
  ike_version      = 2

  session_config = [
    {
      session_name              = "${var.cloud1.prefix}to-onprem"
      peer_asn                  = var.onprem.asn
      cr_bgp_session_range      = "${var.cloud1.router_vti1}/30"
      remote_bgp_session_ip     = var.onprem.router_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${var.cloud1.prefix}to-onprem"
      peer_asn                  = var.onprem.asn
      cr_bgp_session_range      = "${var.cloud1.router_vti2}/30"
      remote_bgp_session_ip     = var.onprem.router_vti2
      advertised_route_priority = 100
    },
  ]
}
