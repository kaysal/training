
output "network" {
  value = {
    vpc_trust   = google_compute_network.vpc_trust
    vpc_untrust = google_compute_network.vpc_untrust
  }
  sensitive = true
}

output "subnetwork" {
  value = {
    eu = {
      trust   = google_compute_subnetwork.cidr_eu_trust
      untrust = google_compute_subnetwork.cidr_eu_untrust
    }
  }
  sensitive = true
}
