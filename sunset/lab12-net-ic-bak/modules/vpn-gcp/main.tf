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

resource "google_compute_vpn_tunnel" "tunnel" {
  provider         = "google-beta"
  project          = "${var.project_id}"
  count            = "${length(var.session_config)}"
  name             = "${lookup(var.session_config[count.index], "session_name")}-${count.index}"
  region           = "${var.region}"
  vpn_gateway      = "${var.vpn_gateway}"
  peer_gcp_gateway = "${var.peer_gcp_gateway}"
  shared_secret    = "${var.shared_secret}"
  router           = "${var.router}"

  vpn_gateway_interface = "${count.index}"
}

resource "google_compute_router_interface" "router_interface" {
  provider   = "google-beta"
  project    = "${var.project_id}"
  count      = "${length(var.session_config)}"
  name       = "${lookup(var.session_config[count.index], "session_name")}-${count.index}"
  router     = "${var.router}"
  region     = "${var.region}"
  ip_range   = "${lookup(var.session_config[count.index], "cr_bgp_session_range")}"
  vpn_tunnel =  "${google_compute_vpn_tunnel.tunnel[count.index].name}"
}

resource "google_compute_router_peer" "router_peer" {
  provider                  = "google-beta"
  project                   = "${var.project_id}"
  count                     = "${length(var.session_config)}"
  name                      = "${lookup(var.session_config[count.index], "session_name")}-${count.index}"
  router                    = "${var.router}"
  region                    = "${var.region}"
  peer_ip_address           = "${lookup(var.session_config[count.index], "remote_bgp_session_ip")}"
  peer_asn                  = "${lookup(var.session_config[count.index], "peer_asn")}"
  advertised_route_priority = "${lookup(var.session_config[count.index], "advertised_route_priority")}"
  interface                 =  "${google_compute_router_interface.router_interface[count.index].name}"
}
