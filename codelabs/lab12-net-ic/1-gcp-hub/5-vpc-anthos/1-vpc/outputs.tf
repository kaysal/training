
output "network" {
  value = {
    vpc_anthos = google_compute_network.vpc_anthos
  }
  sensitive = true
}

output "subnetwork" {
  value = {
    eu = {
      anthos = google_compute_subnetwork.cidr_eu_anthos
    }
  }
  sensitive = true
}
