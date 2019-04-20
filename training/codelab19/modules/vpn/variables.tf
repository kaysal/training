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
}

variable "tunnel_count" {
  description = "The number of tunnels from each VPN gw (default is 1)"
  default     = 1
}

variable "tunnel_name_prefix" {
  description = "The optional custom name of VPN tunnel being created"
  default     = ""
}

variable "peer_ips" {
  type        = "list"
  description = "IP address of remote-peer/gateway"
}

variable "shared_secret" {
  description = "Please enter the shared secret/pre-shared key"
  default     = ""
}

variable "cr_name" {
  description = "The name of cloud router for BGP routing"
  default     = ""
}

variable "peer_asn" {
  type        = "list"
  description = "Please enter the ASN of the BGP peer that cloud router will use"
}

variable "bgp_cr_session_range" {
  type        = "list"
  description = "Please enter the cloud-router interface IP/Session IP"
}

variable "bgp_remote_session_range" {
  type        = "list"
  description = "Please enter the remote environments BGP Session IP"
}

variable "advertised_route_priority" {
  description = "Please enter the priority for the advertised route to BGP peer(default is 100)"
  default     = 100
}

variable "ike_version" {
  description = "Please enter the IKE version used by this tunnel (default is IKEv2)"
  default     = 2
}

variable "prefix" {
  description = "Prefix appended before resource names"
}
