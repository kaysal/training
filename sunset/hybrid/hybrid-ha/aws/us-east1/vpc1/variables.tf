variable "access_key" {
  description = "account access key"
}

variable "secret_key" {
  description = "account secret key"
}

variable "name" {
  description = "general resource prefix"
  default     = "hydra"
}

variable "key_name_eu_west1" {
  description = "Name of the SSH keypair to use in aws us-east1"
}

variable "us_e1_vpc1_cidr" {
  description = "vpc cidr block"
  default     = "172.18.0.0/16"
}

variable "eu_w1_vpc1_172_16_10" {
  description = "subnet"
  default     = "172.16.10.0/24"
}

variable "eu_w1_vpc1_172_16_11" {
  description = "subnet"
  default     = "172.16.11.0/24"
}

variable "us_e1_vpc1_172_18_10" {
  description = "subnet"
  default     = "172.18.10.0/24"
}

variable "us_e1_vpc1_172_18_11" {
  description = "subnet"
  default     = "172.18.11.0/24"
}

variable "gcp_us_e1_vpn_gw1_ip" {
  description = "public IP address of remote vpn gw peer"
}

variable "gcp_us_e1_vpn_gw2_ip" {
  description = "public IP address of remote vpn gw peer"
}

variable "preshared_key" {
  description = "preshared key used for tunnels 1 and 2"
}

variable "aws_side_asn" {
  default = "65010"
}

variable "customer_side_asn" {
  default = "65000"
}
