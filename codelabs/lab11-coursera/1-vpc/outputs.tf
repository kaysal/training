output "network" {
  value     = google_compute_network.vpc
  sensitive = true
}

output "cidrs" {
  value = {
    eu1_cidr     = google_compute_subnetwork.eu1_cidr
    eu2_cidr     = google_compute_subnetwork.eu2_cidr
    eu1_gke_cidr = google_compute_subnetwork.eu1_gke_cidr
    eu2_gke_cidr = google_compute_subnetwork.eu2_gke_cidr
  }
  sensitive = true
}
