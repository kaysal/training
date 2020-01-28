
# vpc

output "vpc" {
  value = {
    network = google_compute_network.onprem_vpc
    subnet  = google_compute_subnetwork.onprem_subnet
  }
  sensitive = true
}
