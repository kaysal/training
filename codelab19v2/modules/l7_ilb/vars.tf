# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "project_id" {
  description = "Project ID"
  default = null
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
