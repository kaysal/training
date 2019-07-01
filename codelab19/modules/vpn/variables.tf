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

variable "project_id" {
  description = "The ID of the project where this VPC will be created"
}

variable "network" {
  description = "The name of VPC being created"
}

variable "region" {
  description = "The region in which you want to create the VPN gateway"
}

variable "gateway_name" {
  description = "The name of VPN gateway"
  default     = "test-vpn"
}

variable "gateway_ip" {
  description = "The IP of VPN gateway"
  default     = null
}

variable "shared_secret" {
  description = "Please enter the shared secret/pre-shared key"
  default     = ""
}

variable "cr_name" {
  description = "The name of cloud router for BGP routing"
  default     = ""
}

variable "advertised_route_priority" {
  description = "Please enter the priority for the advertised route to BGP peer(default is 100)"
  default     = 100
}

variable "ike_version" {
  description = "Please enter the IKE version used by this tunnel (default is IKEv2)"
  default     = 2
}

variable "peer_ips" {
  description = "List of IP addresses of peer VPN Gateways"
}

variable "tunnel_config" {
  type        = "list"
  description = "IPsec tunnel and BGP session parameters"
}
