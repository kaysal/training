variable "project_id" {
  description = "Project ID"
}

variable "global" {
  description = "variable map to hold all global config values"
  type        = any
}

variable "hub" {
  description = "variable map for main project"
  type        = any
}

variable "spoke" {
  description = "variable map for peer project"
  type        = any
}

variable "interconnect_project_id" {
  description = "Interconnect Project ID"
}
