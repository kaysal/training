
variable "project_id_cloud" {
  description = "The ID of the cloud project where this VPC will be created"
}

variable "global" {
  description = "variable map to hold all global config values"
  type        = any
}

variable "cloud" {
  description = "variable map to hold all cloud VPC config values"
  type        = any
}
