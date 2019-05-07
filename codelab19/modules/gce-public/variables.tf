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

variable "tags" {
  type        = "list"
  description = "network tags"
  default     = []
}
