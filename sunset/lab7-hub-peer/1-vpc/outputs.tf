output "networks" {
  value = {
    onprem = google_compute_network.onprem_vpc
    hub    = google_compute_network.hub_vpc
    spoke1 = google_compute_network.spoke1_vpc
    spoke2 = google_compute_network.spoke2_vpc
  }
}

output "cidrs" {
  value = {
    onprem_a = google_compute_subnetwork.onprem_subnet_a
    onprem_b = google_compute_subnetwork.onprem_subnet_b
    hub_a    = google_compute_subnetwork.hub_subnet_a
    hub_b    = google_compute_subnetwork.hub_subnet_b
    spoke1_a = google_compute_subnetwork.spoke1_subnet_a
    spoke1_b = google_compute_subnetwork.spoke1_subnet_b
    spoke2_a = google_compute_subnetwork.spoke2_subnet_a
    spoke2_b = google_compute_subnetwork.spoke2_subnet_b
  }
}
