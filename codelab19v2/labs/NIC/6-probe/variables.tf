
variable "project_id_vpc1" {
  description = "The ID of the vpc1 project where this VPC will be created"
}

variable "project_id_vpc2" {
  description = "The ID of the vpc2 project where this VPC will be created"
}

variable "global" {
  description = "variable map to hold all global config values"
  type        = any
}

variable "vpc1" {
  description = "variable map to hold all vpc1 VPC config values"
  type        = any
}

variable "vpc2" {
  description = "variable map to hold all vpc2 VPC config values"
  type        = any
}
