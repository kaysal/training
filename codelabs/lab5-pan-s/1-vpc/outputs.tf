output "networks" {
  value = {
    onprem  = google_compute_network.onprem_vpc
    untrust = google_compute_network.untrust_vpc
    trust   = google_compute_network.trust_vpc
    mgt     = google_compute_network.mgt_vpc
    zone1   = google_compute_network.zone1_vpc
  }
  sensitive = true
}

output "subnets" {
  value = {
    onprem  = google_compute_subnetwork.onprem_subnet
    untrust = google_compute_subnetwork.untrust_subnet
    trust   = google_compute_subnetwork.trust_subnet
    mgt     = google_compute_subnetwork.mgt_subnet
    zone1   = google_compute_subnetwork.zone1_subnet
  }
  sensitive = true
}
