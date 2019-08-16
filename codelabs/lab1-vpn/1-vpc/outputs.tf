output "networks" {
  value = {
    onprem = google_compute_network.onprem_vpc
    cloud  = google_compute_network.cloud_vpc
  }
}

output "subnets" {
  value = {
    onprem = google_compute_subnetwork.onprem_subnet
    cloud  = google_compute_subnetwork.cloud_subnet
  }
}
