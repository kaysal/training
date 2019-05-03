variable "project_id" {
  description = "Project ID"
}

variable "network" {
  description = "VPC name"
  default     = "default"
}

variable "subnetwork" {
  description = "Subnetwork"
  default     = "default"
}

variable "subnetwork_project" {
  description = "Subnetwork project"
}

variable "region" {
  description = "GCP region"
}

variable "prefix" {
  description = "Prefix appended before resource names"
}

variable "instance_template_name" {
  description = "instance template name"
}

variable "machine_type" {
  description = "machine type"
  default     = "n1-standard-1"
}

variable "image" {
  description = "OS image"
  default     = "debian-cloud/debian-9"
}

variable "metadata_startup_script" {
  description = "metadata startup script"
}

variable "tags" {
  type        = "list"
  description = "network tags"
  default     = []
}

variable "instance_group_name" {
  description = "instance group name"
}

variable "distribution_policy_zones" {
  type = "list"
  description = "instance group zone distibution"
}

variable "target_size" {
  description = "instance group zone"
}
