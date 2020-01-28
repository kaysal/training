variable "project_id" {
  description = "Project ID"
}

variable "global" {
  description = "variable map to hold all global config values"
  type        = any
}

variable "default" {
  description = "variable map to hold all default VPC config values"
  type        = any
}

variable "peering" {
  description = "variable map to hold all net-peering VPC config values"
  type        = any
}
