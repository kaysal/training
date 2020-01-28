
# random

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# vpc1
#---------------------------------------------

# cloud router

resource "google_compute_router" "vpc1_router_vpn" {
  project = var.project_id
  name    = "vpc1-router-vpn"
  network = local.vpc1.self_link
  region  = var.hub.vpc1.eu.region
  bgp {
    asn               = var.hub.vpc1.eu.vpn.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges { range = "172.16.16.16" }
  }
}

# ha vpn gateway

resource "google_compute_ha_vpn_gateway" "vpc1_ha_vpn" {
  provider = google-beta
  project  = var.project_id
  region   = var.hub.vpc1.eu.region
  name     = "vpc1-ha-vpn"
  network  = local.vpc1.self_link
}

# vpn tunnels

module "vpn_vpc1_to_vpc2" {
  source           = "../../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = local.vpc1.self_link
  region           = var.hub.vpc1.eu.region
  vpn_gateway      = google_compute_ha_vpn_gateway.vpc1_ha_vpn.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.vpc2_ha_vpn.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = google_compute_router.vpc1_router_vpn.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "vpc1-to-vpc2"
      peer_asn                  = var.hub.vpc2.eu.vpn.asn
      cr_bgp_session_range      = "${var.hub.vpc1.eu.vpn.cr_vti1}/30"
      remote_bgp_session_ip     = var.hub.vpc2.eu.vpn.cr_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "vpc1-to-vpc2"
      peer_asn                  = var.hub.vpc2.eu.vpn.asn
      cr_bgp_session_range      = "${var.hub.vpc1.eu.vpn.cr_vti2}/30"
      remote_bgp_session_ip     = var.hub.vpc2.eu.vpn.cr_vti2
      advertised_route_priority = 100
    },
  ]
}

# vpc2
#---------------------------------------------

# cloud router

resource "google_compute_router" "vpc2_router_vpn" {
  project = var.project_id
  name    = "vpc2-router-vpn"
  network = local.vpc2.self_link
  region  = var.hub.vpc2.eu.region
  bgp {
    asn               = var.hub.vpc2.eu.vpn.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# ha vpn gateway

resource "google_compute_ha_vpn_gateway" "vpc2_ha_vpn" {
  provider = google-beta
  project  = var.project_id
  region   = var.hub.vpc2.eu.region
  name     = "vpc2-ha-vpn"
  network  = local.vpc2.self_link
}

# vpn tunnels

module "vpc2_to_vpc1" {
  source           = "../../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = local.vpc2.self_link
  region           = var.hub.vpc2.eu.region
  vpn_gateway      = google_compute_ha_vpn_gateway.vpc2_ha_vpn.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.vpc1_ha_vpn.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = google_compute_router.vpc2_router_vpn.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "vpc2-to-vpc1"
      peer_asn                  = var.hub.vpc1.eu.vpn.asn
      cr_bgp_session_range      = "${var.hub.vpc2.eu.vpn.cr_vti1}/30"
      remote_bgp_session_ip     = var.hub.vpc1.eu.vpn.cr_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "vpc2-to-vpc1"
      peer_asn                  = var.hub.vpc1.eu.vpn.asn
      cr_bgp_session_range      = "${var.hub.vpc2.eu.vpn.cr_vti2}/30"
      remote_bgp_session_ip     = var.hub.vpc1.eu.vpn.cr_vti2
      advertised_route_priority = 100
    },
  ]
}
