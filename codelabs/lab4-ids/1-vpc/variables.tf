variable "project_id" {
  description = "The ID of the project where this VPC will be created"
}

variable "global" {
  description = "variable map to hold all global config values"
  type        = any
}

variable "vpc1" {
  description = "variable map to hold all vpc1 VPC config values"
  type        = map
}

variable "vpc2" {
  description = "variable map to hold all vpc2 VPC config values"
  type        = map
}
