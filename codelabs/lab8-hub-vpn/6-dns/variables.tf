variable "project_id_onprem" {
  description = "The ID of the onprem project where this VPC will be created"
}

variable "project_id_hub" {
  description = "The ID of the hub project where this VPC will be created"
}

variable "project_id_spoke1" {
  description = "The ID of the spoke1 project where this VPC will be created"
}

variable "project_id_spoke2" {
  description = "The ID of the spoke2 project where this VPC will be created"
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

variable "spoke1" {
  description = "variable map to hold all spoke1 VPC config values"
  type        = map
}

variable "spoke2" {
  description = "variable map to hold all spoke2 VPC config values"
  type        = map
}

variable "restricted_apis" {
  description = "list of Restrcited Google APIs for Private Google Access"
  type        = list
}
