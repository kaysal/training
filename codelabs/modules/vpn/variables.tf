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
  type        = string
  description = "The ID of the project where this VPC will be created"
}

variable "network" {
  type        = string
  description = "The name of VPC being created"
}

variable "region" {
  type        = string
  description = "The region in which you want to create the VPN gateway"
}

variable "gateway" {
  type        = string
  description = "The URI of the VPN gateway"
}

variable "tunnel_name" {
  type        = string
  description = "The optional custom name of VPN tunnel being created"
}

variable "ike_version" {
  type        = number
  description = "Please enter the IKE version used by this tunnel (default is IKEv2)"
  default     = 2
}

variable "peer_ip" {
  type        = string
  description = "IP address of remote-peer/gateway"
}

variable "shared_secret" {
  type        = string
  description = "Please enter the shared secret/pre-shared key"
  default     = ""
}

# static tunnel

variable "local_traffic_selector" {
  description = "local traffic selector or proxy IDs"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "remote_traffic_selector" {
  description = "remote traffic selector or proxy IDs"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "remote_ip_cidr_ranges" {
  description = "remote subnet ip range in CIDR format - x.x.x.x/x"
  type        = list(string)
  default     = []
}

variable "static_route_priority" {
  description = "Priority for static route being created"
  default     = 100
}

# dynamic tunnel

variable "cr_name" {
  type        = string
  description = "The name of cloud router for BGP routing"
  default     = ""
}

variable "peer_asn" {
  type        = string
  description = "Please enter the ASN of the BGP peer that cloud router will use"
  default     = "65101"
}

variable "bgp_cr_session_range" {
  type        = string
  description = "Please enter the cloud-router interface IP/Session IP"
  default     = "169.254.1.1/30"
}

variable "bgp_remote_session_range" {
  type        = string
  description = "Please enter the remote environments BGP Session IP"
  default     = "169.254.1.2"
}

variable "advertised_route_priority" {
  description = "Please enter the priority for the advertised route to BGP peer(default is 100)"
  default     = 100
}
