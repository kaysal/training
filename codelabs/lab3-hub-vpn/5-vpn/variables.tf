variable "project_id" {
  description = "The ID of the project where this VPC will be created"
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
