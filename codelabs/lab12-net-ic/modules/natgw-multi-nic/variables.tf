
variable "project" {
  description = "Project ID"
}

variable "prefix" {
  description = "resource prefix"
}

variable "zone" {
  description = "instance zone"
}

variable "natgw_tags" {
  description = "natgw instance tags"
  type        = list
  default     = ["tag"]
}

variable "route_tags" {
  description = "route tags to be applied to instances"
  type        = list
  default     = ["tag"]
}

variable "machine_type" {
  description = "instance spec"
  default     = "n1-standard-1"
}
variable "trust_subnet" {
  description = "trust subnetwork self_link"
}

variable "untrust_subnet" {
  description = "untrust subnetwork self_link"
}

variable "trust_ip" {
  description = "trust vpc pre-allocated static private ip"
}

variable "trust_ip_dgw" {
  description = "default gw ip of trust subnetwork"
}

variable "untrust_ip" {
  description = "untrust vpc pre-allocated static private ip"
}

variable "untrust_nat_ip" {
  description = "untrust vpc pre-allocated static nat ip"
}

variable "vpc_trust" {
  description = "vpc trust network"
}
