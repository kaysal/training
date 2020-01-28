
# random

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# default
#---------------------------------------------

# cloud router

resource "google_compute_router" "default_router_vpn" {
  project = var.project_id
  name    = "default-router-vpn"
  network = local.default.self_link
  region  = var.hub.default.eu.region
  bgp {
    asn               = var.hub.default.eu.vpn.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges { range = "172.16.16.16" }
  }
}

# ha vpn gateway

resource "google_compute_ha_vpn_gateway" "default_ha_vpn" {
  provider = "google-beta"
  project  = var.project_id
  region   = var.hub.default.eu.region
  name     = "default-ha-vpn"
  network  = local.default.self_link
}

# vpn tunnels

module "vpn_default_to_custom" {
  source           = "../../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = local.default.self_link
  region           = var.hub.default.eu.region
  vpn_gateway      = google_compute_ha_vpn_gateway.default_ha_vpn.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.custom_ha_vpn.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = google_compute_router.default_router_vpn.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "default-to-custom"
      peer_asn                  = var.hub.custom.eu.vpn.asn
      cr_bgp_session_range      = "${var.hub.default.eu.vpn.cr_vti1}/30"
      remote_bgp_session_ip     = var.hub.custom.eu.vpn.cr_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "default-to-custom"
      peer_asn                  = var.hub.custom.eu.vpn.asn
      cr_bgp_session_range      = "${var.hub.default.eu.vpn.cr_vti2}/30"
      remote_bgp_session_ip     = var.hub.custom.eu.vpn.cr_vti2
      advertised_route_priority = 100
    },
  ]
}

# custom
#---------------------------------------------

# cloud router

resource "google_compute_router" "custom_router_vpn" {
  project = var.project_id
  name    = "custom-router-vpn"
  network = local.custom.self_link
  region  = var.hub.custom.eu.region
  bgp {
    asn               = var.hub.custom.eu.vpn.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# ha vpn gateway

resource "google_compute_ha_vpn_gateway" "custom_ha_vpn" {
  provider = "google-beta"
  project  = var.project_id
  region   = var.hub.custom.eu.region
  name     = "custom-ha-vpn"
  network  = local.custom.self_link
}

# vpn tunnels

module "custom_to_default" {
  source           = "../../../modules/vpn-gcp"
  project_id       = var.project_id
  network          = local.custom.self_link
  region           = var.hub.custom.eu.region
  vpn_gateway      = google_compute_ha_vpn_gateway.custom_ha_vpn.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.default_ha_vpn.self_link
  shared_secret    = random_id.ipsec_secret.b64_url
  router           = google_compute_router.custom_router_vpn.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "custom-to-default"
      peer_asn                  = var.hub.default.eu.vpn.asn
      cr_bgp_session_range      = "${var.hub.custom.eu.vpn.cr_vti1}/30"
      remote_bgp_session_ip     = var.hub.default.eu.vpn.cr_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "custom-to-default"
      peer_asn                  = var.hub.default.eu.vpn.asn
      cr_bgp_session_range      = "${var.hub.custom.eu.vpn.cr_vti2}/30"
      remote_bgp_session_ip     = var.hub.default.eu.vpn.cr_vti2
      advertised_route_priority = 100
    },
  ]
}
