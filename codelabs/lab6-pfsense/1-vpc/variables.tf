variable "project_id" {
  description = "The ID of the project where this VPC will be created"
}

variable "global" {
  description = "variable map to hold all global config values"
  type        = any
}

variable "onprem" {
  description = "variable map to hold all onprem VPC config values"
  type        = map
}

variable "untrust" {
  description = "variable map to hold all untrust VPC config values"
  type        = map
}

variable "trust" {
  description = "variable map to hold all trust VPC config values"
  type        = map
}
