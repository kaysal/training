output "networks" {
  value = {
    cloud = {
      network = google_compute_network.cloud_vpc
    }
  }
  sensitive = true
}

output "cidrs" {
  value = {
    cloud = {
      eu_subnet   = google_compute_subnetwork.cloud_eu_subnet
      asia_subnet = google_compute_subnetwork.cloud_asia_subnet
      us_subnet   = google_compute_subnetwork.cloud_us_subnet
    }
  }
  sensitive = true
}
