output "network" {
  value = {
    vpc = google_compute_network.vpc
    subnet = google_compute_subnetwork.subnet
  }
  
  sensitive = true
}
