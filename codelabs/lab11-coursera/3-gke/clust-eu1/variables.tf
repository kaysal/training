
variable "project_id" {
  description = "The ID of the project where this VPC will be created"
}

variable "global" {
  description = "variable map to hold all global config values"
  type        = any
}

variable "orange" {
  description = "variable map to hold all shared-svc VPC config values"
  type        = any
}
