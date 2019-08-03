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
    prefix            = "lab1-onprem-"
    region            = "europe-west1"
    router_vti1       = "169.254.100.1"
    router_vti2       = "169.254.100.5"
    asn               = "65001"
    router            = data.terraform_remote_state.router.outputs.router.onprem.name
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.onprem.network.self_link
  }

  cloud = {
    prefix            = "lab1-cloud-"
    region            = "europe-west1"
    router_vti1       = "169.254.100.2"
    router_vti2       = "169.254.100.6"
    asn               = "65002"
    router            = data.terraform_remote_state.router.outputs.router.cloud.name
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud.network.self_link
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
  region   = local.onprem.region
  name     = "${local.onprem.prefix}vpn-gw"
  network  = local.onprem.network_self_link
}

# vpn tunnel

module "vpn_onprem_to_cloud" {
  source           = "../../modules/vpn-ha-gcp"
  network          = local.onprem.network_self_link
  region           = local.onprem.region
  vpn_gateway      = google_compute_ha_vpn_gateway.onprem_vpn_gw.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.cloud_vpn_gw.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = data.terraform_remote_state.router.outputs.router.onprem.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${local.onprem.prefix}to-cloud"
      peer_asn                  = local.cloud.asn
      cr_bgp_session_range      = "${local.onprem.router_vti1}/30"
      remote_bgp_session_ip     = local.cloud.router_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${local.onprem.prefix}to-cloud"
      peer_asn                  = local.cloud.asn
      cr_bgp_session_range      = "${local.onprem.router_vti2}/30"
      remote_bgp_session_ip     = local.cloud.router_vti2
      advertised_route_priority = 100
    },
  ]
}

# cloud configuration
#---------------------------------------------

# vpn gateway

resource "google_compute_ha_vpn_gateway" "cloud_vpn_gw" {
  provider = "google-beta"
  region   = local.cloud.region
  name     = "${local.cloud.prefix}vpn-gw"
  network  = local.cloud.network_self_link
}

# vpn tunnel

module "vpn_cloud_to_onprem" {
  source           = "../../modules/vpn-ha-gcp"
  project_id       = var.project_id
  network          = local.cloud.network_self_link
  region           = local.cloud.region
  vpn_gateway      = google_compute_ha_vpn_gateway.cloud_vpn_gw.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.onprem_vpn_gw.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = data.terraform_remote_state.router.outputs.router.cloud.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${local.cloud.prefix}to-onprem"
      peer_asn                  = local.onprem.asn
      cr_bgp_session_range      = "${local.cloud.router_vti1}/30"
      remote_bgp_session_ip     = local.onprem.router_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${local.cloud.prefix}to-onprem"
      peer_asn                  = local.onprem.asn
      cr_bgp_session_range      = "${local.cloud.router_vti2}/30"
      remote_bgp_session_ip     = local.onprem.router_vti2
      advertised_route_priority = 100
    },
  ]
}
