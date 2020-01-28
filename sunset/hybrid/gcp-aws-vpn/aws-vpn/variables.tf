variable "region" {
    description = "aws region"
}
variable "access_key" {
    description = "account access key"
}
variable "secret_key" {
    description = "account secret key"
}

variable "name" {
    description = "The name of the VPC."
}
variable "cidr_block" {
    description = "The CIDR block for the VPC."
    default = "10.0.0.0/16"
}

variable "key_name" {
  default = "Name of the SSH keypair to use in AWS."
}

variable "vpn_ip_address" {
    description = "Internet-routable IP address of the customer gateway's external interface."
}
variable "vpn_dst_cidr_block" {
    description = "Internal network IP range to advertise over the VPN connection to the VPC."
    default = "172.16.0.0/16"
}
variable "vpn_bgp_asn" {
    description = "BPG Autonomous System Number (ASN) of the customer gateway for a dynamically routed VPN connection."
    default = "65000"
}

variable "zone" {
    description = "availability zone to use."
}

variable "private_subnet" {
    description = "CIDR block to use as private subnet; instances launced will NOT be assigned a public IP address."
    default = "10.0.1.0/24"
}
variable "enable_dns_hostnames" {
    description = "Enable DNS hostnames in the VPC (default false)."
    default = false
}
variable "enable_dns_support" {
    description = "Enable DNS support in the VPC (default true)."
    default = true
}

variable "amis" {
  description = "AMI of free tier instance"
  default = {
    "eu-west-2" = "ami-6d263d09"
  }
}

variable "preshared_key" {
    description = "preshaed key used for tunnels 1 and 2"
}

variable "gcp_bastion_cidr" {
    description = "remote GCP bastion subnet"
    default = "172.16.1.0/24"
}

variable "gcp_lb_cidr" {
    description = "remote GCP loadbalancer subnet"
    default = "172.16.10.0/24"
}
