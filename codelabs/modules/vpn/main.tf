/**
 * Copyright 2018 Google LLC
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

# static
#-------------------------------------
## static tunnel

resource "google_compute_vpn_tunnel" "tunnel_static" {
  count                   = var.cr_name == "" ? 1 : 0
  project                 = var.project_id
  region                  = var.region
  name                    = var.tunnel_name
  peer_ip                 = var.peer_ip
  shared_secret           = var.shared_secret
  target_vpn_gateway      = var.gateway
  local_traffic_selector  = var.local_traffic_selector
  remote_traffic_selector = var.remote_traffic_selector
  ike_version             = var.ike_version
}

## static routes for static tunnels

resource "google_compute_route" "route" {
  count               = var.cr_name == "" ? length(var.remote_ip_cidr_ranges) : 0
  name                = "${var.tunnel_name}-${count.index}"
  project             = var.project_id
  network             = var.network
  dest_range          = var.remote_ip_cidr_ranges[count.index]
  priority            = var.static_route_priority
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel_static[0].self_link
}

# dynamic
#-------------------------------------
## dynamic tunnel

resource "google_compute_vpn_tunnel" "tunnel_dynamic" {
  count              = var.cr_name == "" ? 0 : 1
  project            = var.project_id
  region             = var.region
  name               = var.tunnel_name
  peer_ip            = var.peer_ip
  shared_secret      = var.shared_secret
  target_vpn_gateway = var.gateway
  router             = var.cr_name
  ike_version        = var.ike_version
}

## cloud router interface

resource "google_compute_router_interface" "router_interface" {
  count      = var.cr_name == "" ? 0 : 1
  project    = var.project_id
  region     = var.region
  name       = var.tunnel_name
  vpn_tunnel = var.tunnel_name
  router     = var.cr_name
  ip_range   = var.bgp_cr_session_range

  depends_on = [google_compute_vpn_tunnel.tunnel_dynamic]
}

## bgp peer configuration

resource "google_compute_router_peer" "bgp_peer" {
  count                     = var.cr_name == "" ? 0 : 1
  project                   = var.project_id
  region                    = var.region
  name                      = var.tunnel_name
  router                    = var.cr_name
  peer_ip_address           = var.bgp_remote_session_range
  peer_asn                  = var.peer_asn
  advertised_route_priority = var.advertised_route_priority
  interface                 = var.tunnel_name

  depends_on = [google_compute_router_interface.router_interface]
}
