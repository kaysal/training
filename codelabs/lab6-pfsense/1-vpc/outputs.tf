output "networks" {
  value = {
    untrust = google_compute_network.untrust_vpc
    trust   = google_compute_network.trust_vpc
  }
}

output "subnets" {
  value = {
    untrust = {
      subnet1 = google_compute_subnetwork.untrust_subnet1
    }
    trust = {
      subnet1 = google_compute_subnetwork.trust_subnet1
      subnet2 = google_compute_subnetwork.trust_subnet2
    }
  }
  sensitive = true
}
