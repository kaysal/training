variable "project_id" {
  description = "The ID of the project where this VPC will be created"
}

variable "global" {
  description = "variable map to hold all global config values"
  type        = any
}

variable "onprem" {
  description = "variable map to hold all onprem VPC config values"
  type        = any
}

variable "untrust" {
  description = "variable map to hold all untrust VPC config values"
  type        = any
}

variable "trust" {
  description = "variable map to hold all trust VPC config values"
  type        = any
}

variable "mgt" {
  description = "variable map to hold all mgt VPC config values"
  type        = any
}

variable "east" {
  description = "variable map to hold all east VPC config values"
  type        = any
}
