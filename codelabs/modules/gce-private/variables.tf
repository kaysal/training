/**
 * Copyright 2019 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "project id where resources belong to"
  default     = null
}

variable "name" {
  description = "vm instance name"
}

variable "subnetwork_project" {
  description = "the project that the vm's subnet belongs to"
  default     = null
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

variable "network_ip" {
  description = "The private IP address to assign to the instance"
  default     = null
}

variable "nat_ip" {
  description = "The IP address that will be 1:1 mapped to the instance's network ip"
  default     = null
}

variable "network_tier" {
  description = "The network tier of the VM"
  default     = "STANDARD"
}

variable "public_ptr_domain_name" {
  description = "The DNS domain name for the public PTR record"
  default     = null
}

variable "metadata_startup_script" {
  description = "metadata startup script"
  default     = null
}
variable "can_ip_forward" {
  description = "Whether to allow sending and receiving of packets with non-matching source or destination IPs"
  default     = false
}

variable "service_account_email" {
  description = "service account to attach to the instance"
  default     = null
}

variable "tags" {
  type        = "list"
  description = "network tags"
  default     = null
}
