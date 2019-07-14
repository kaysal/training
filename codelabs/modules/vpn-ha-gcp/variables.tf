
variable "project_id" {
  description = "The ID of the project where this VPC will be created"
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
  type        = "list"
  description = "The list of configurations of the vpn tunnels and bgp sessions being created"
}
