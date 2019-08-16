output "networks" {
  value = {
    onprem = google_compute_network.onprem_vpc
    cloud1 = google_compute_network.cloud1_vpc
    cloud2 = google_compute_network.cloud2_vpc
    cloud3 = google_compute_network.cloud3_vpc
  }
}

output "subnets" {
  value = {
    onprem = google_compute_subnetwork.onprem_subnet
    cloud1 = google_compute_subnetwork.cloud1_subnet
    cloud2 = google_compute_subnetwork.cloud2_subnet
    cloud3 = google_compute_subnetwork.cloud3_subnet
  }
}
