variable "name" {
  description = "Bastion host name"
}

variable "project" {
  description = "Project where the instance will be created"
}

variable "subnetwork_project" {
  description = "Project where the subnetwork will be created"
}

variable "machine_type" {
  description = "machine type"
  default     = "f1-micro"
}

variable "zone" {
  description = "GCE zone"
}

variable "image" {
  description = "OS image"
  default     = "debian-cloud/debian-9"
}

variable "network" {
  description = "The VPC where the instance will be created"
  default     = "default"
}

variable "subnetwork" {
  description = "The VPC subnetwork where the instance will be created"
  default     = "default"
}

variable "metadata_startup_script" {
  description = "metadata startup script"
}
