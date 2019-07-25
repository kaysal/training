
# onprem
#---------------------------------------------

# vpn gateway

resource "google_compute_ha_vpn_gateway" "onprem_vpn_gw" {
  provider = "google-beta"
  region   = local.onprem.region
  name     = "${local.onprem.prefix}vpn-gw"
  network  = module.vpc_onprem.network.self_link
}

# vpn tunnel

module "vpn_onprem_to_cloud" {
  source           = "../modules/vpn-ha-gcp"
  network          = module.vpc_onprem.network.self_link
  region           = local.onprem.region
  vpn_gateway      = google_compute_ha_vpn_gateway.onprem_vpn_gw.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.cloud_vpn_gw.self_link
  shared_secret    = var.psk
  router           = google_compute_router.onprem_router.name
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
  network  = module.vpc_cloud.network.self_link
}

# vpn tunnel

module "vpn_cloud_to_onprem" {
  source           = "../modules/vpn-ha-gcp"
  project_id       = var.project_id
  network          = module.vpc_cloud.network.self_link
  region           = local.cloud.region
  vpn_gateway      = google_compute_ha_vpn_gateway.cloud_vpn_gw.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.onprem_vpn_gw.self_link
  shared_secret    = var.psk
  router           = google_compute_router.cloud_router.name
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
