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
 
# onprem
#---------------------------------------------

# vm instance

module "vm_onprem" {
  source     = "../modules/gce-private"
  name       = "${local.onprem.prefix}vm"
  zone       = "${local.onprem.region}-b"
  subnetwork = module.vpc_onprem.subnets.*.self_link[0]
}

# hub
#---------------------------------------------

# vm instance

module "vm_hub" {
  source     = "../modules/gce-private"
  name       = "${local.hub.prefix}vm"
  zone       = "${local.hub.region}-b"
  subnetwork = module.vpc_hub.subnets.*.self_link[0]
}
