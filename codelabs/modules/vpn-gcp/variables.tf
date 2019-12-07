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

variable "project_id" {
  description = "project id where resources belong to"
  default     = null
}

variable "network" {
  description = "The name of VPC being created"
}

variable "region" {
  description = "The VPN gateway region"
}

variable "vpn_gateway" {
  description = "self_link of HA VPN gateway"
}

variable "peer_gcp_gateway" {
  description = "self_link of peer GCP VPN gateway"
}

variable "shared_secret" {
  description = "VPN tunnel pre-shared key"
}

variable "router" {
  description = "The name of cloud router for BGP routing"
}

variable "advertised_route_priority" {
  description = "Priority for the advertised route to BGP peer (default is 100)"
  default     = 100
}

variable "ike_version" {
  description = "IKE version used by the tunnel (default is IKEv2)"
  default     = 2
}

variable "session_config" {
  type        = list
  description = "The list of configurations of the vpn tunnels and bgp sessions being created"
}
