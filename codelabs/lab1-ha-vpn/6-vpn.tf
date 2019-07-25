/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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


# cloud
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
