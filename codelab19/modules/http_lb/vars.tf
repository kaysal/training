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

variable "health_check_name" {
  description = "health check name"
}

variable "named_port" {
  type        = "map"
  description = "named port map"

  default = {
    name = "http"
    port = "80"
  }
}

variable "autoscaler_max_replicas" {
  description = "autoscaler maximum replicas"
  default     = 3
}

variable "autoscaler_min_replicas" {
  description = "autoscaler minimum replicas"
  default     = 1
}

variable "autoscaler_cooldown_period" {
  description = "autoscaler-cooldown-period"
  default     = 45
}

variable "autoscaler_cpu_utilization_target" {
  description = "autoscaler cpu utilization target"
  default     = 0.8
}

variable "url_map_name" {
  description = "url map name"
  default     = "url-map"
}

variable "backend_service_name" {
  description = "backend service name"
  default     = "backend-service"
}

variable "target_proxy_name" {
  description = "target proxy name"
  default     = "proxy"
}

variable "forwarding_rule_name" {
  description = "forwarding rule name"
  default     = "proxy"
}
