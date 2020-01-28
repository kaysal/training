
output "network" {
  value = {
    vpc2 = google_compute_network.vpc2
  }
  sensitive = true
}

output "subnetwork" {
  value = {
    eu = {
      nic = google_compute_subnetwork.nic2_cidr_eu
    }
    us = {
      data = google_compute_subnetwork.data_cidr_us
    }
  }
  sensitive = true
}
