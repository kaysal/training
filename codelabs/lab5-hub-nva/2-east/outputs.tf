output "network" {
  value     = google_compute_network.east_vpc
  sensitive = true
}

output "subnet" {
  value     = google_compute_subnetwork.east_subnet
  sensitive = true
}
