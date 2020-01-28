variable "project_id_onprem" {
  description = "The ID of the onprem project where this VPC will be created"
}

variable "project_id_hub" {
  description = "The ID of the hub project where this VPC will be created"
}

variable "project_id_svc" {
  description = "The ID of the spoke1 project where this VPC will be created"
}

variable "global" {
  description = "variable map to hold all global config values"
  type        = any
}

variable "onprem" {
  description = "variable map to hold all on-premises VPC config values"
  type        = any
}

variable "hub" {
  description = "variable map to hold all hub VPC config values"
  type        = any
}

variable "svc" {
  description = "variable map to hold all shared-svc VPC config values"
  type        = any
}

variable "onprem_zones" {
  description = "variable map to hold onprem dns names"
  type        = any
}

variable "onprem_forward_ns" {
  description = "variable map to hold corresponding name servers"
  type        = any
}

variable "hub_zones" {
  description = "variable map to hold hub local zones"
  type        = any
}

variable "hub_dns" {
  description = "variable map to hold hub dns names"
  type        = any
}

variable "hub_records" {
  description = "variable map to hold hub dns records"
  type        = any
}
