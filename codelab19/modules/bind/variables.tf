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

variable "network_project" {
  description = "Project where the network will be created"
}

variable "network" {
  description = "The VPC where the elk-stack instance will be created"
  default     = "default"
}

variable "subnetwork" {
  description = "The VPC subnetwork where instance will be created"
  default     = "default"
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

variable "disk_type" {
  description = "Disk type - [pd-standard pd-ssd]"
  default     = "pd-standard"
}

variable "disk_size" {
  description = "Disk size"
  default     = "10"
}

variable "project" {}
variable "name_server" {}
variable "domain_name" {}
variable "domain_name_search" {}
variable "local_forwarders" {}
variable "local_name_server_ip" {}
variable "local_zone" {}
variable "local_zone_file" {}
variable "local_zone_inv" {}
variable "local_zone_inv_file" {}
variable "gcp_dns_range" {}
variable "googleapis_zone" {}
variable "googleapis_zone_file" {}
variable "remote_zone_gcp" {}
variable "remote_ns_gcp" {}
