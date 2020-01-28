output "network" {
  value     = google_compute_network.west_vpc
  sensitive = true
}

output "subnet" {
  value     = google_compute_subnetwork.west_subnet
  sensitive = true
}
