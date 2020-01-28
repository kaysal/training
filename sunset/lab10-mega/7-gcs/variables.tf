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
  type        = map
}

variable "hub" {
  description = "variable map to hold all hub VPC config values"
  type        = map
}

variable "svc" {
  description = "variable map to hold all shared-svc VPC config values"
  type        = map
}
