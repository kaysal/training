# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

output "name" {
  value = "${google_container_cluster.cluster.name}"
}

output "endpoint" {
  value = "${google_container_cluster.cluster.endpoint}"
}

output "master_version" {
  value = "${google_container_cluster.cluster.master_version}"
}

/*output "client_certificate" {
  value = "${google_container_cluster.cluster.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.cluster.master_auth.0.client_key}"
}*/

output "cluster_ca_certificate" {
  value = "${google_container_cluster.cluster.master_auth.0.cluster_ca_certificate}"
}

output "unique_id" {
  value = "${substr(md5(google_container_cluster.cluster.endpoint), 0, 8)}"
}

output "region" {
  value = "${google_container_cluster.cluster.region}"
}
