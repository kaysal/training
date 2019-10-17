/**
 * Copyright 2018 Google LLC
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
   type        = string
   description = "The ID of the project where this VPC will be created"
 }

 variable "network" {
   type        = string
   description = "The name of VPC being created"
 }

 variable "region" {
   type        = string
   description = "The region in which you want to create the VPN gateway"
 }

 variable "gateway_name" {
   type        = string
   description = "The name of the VPN gateway"
 }

variable "prefix" {
  description = "Prefix appended before resource names"
  default = ""
}
