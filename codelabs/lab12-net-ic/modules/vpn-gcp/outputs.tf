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

output "vpn_gateway" {
  description = "The Gateway resource with all attributes"
  value       = "${var.vpn_gateway}"
}

output "vpn_tunnels" {
  description = "The VPN tunnel resource and with all attributes"
  value       = "${google_compute_vpn_tunnel.tunnel.*}"
}

output "router_interface" {
  description = "The router interface names"
  value       = "${google_compute_router_interface.router_interface.*}"
}
