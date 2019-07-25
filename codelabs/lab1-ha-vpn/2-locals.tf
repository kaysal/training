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

# local variables

locals {
  onprem = {
    prefix      = "lab1-onprem-"
    region      = "europe-west1"
    asn         = 65001
    router_vti1 = "169.254.100.1"
    router_vti2 = "169.254.100.5"
    subnet1     = "onprem-subnet1"
  }

  cloud = {
    prefix      = "lab1-cloud-"
    region      = "europe-west1"
    asn         = 65002
    router_vti1 = "169.254.100.2"
    router_vti2 = "169.254.100.6"
    subnet1     = "cloud-subnet1"
  }
}
