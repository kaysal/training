output "networks" {
  value = {
    vpc1 = {
      network = google_compute_network.vpc1_vpc
    }
    vpc2 = {
      network = google_compute_network.vpc2_vpc
    }
  }
  sensitive = true
}

output "cidrs" {
  value = {
    vpc1 = {
      eu_subnet   = google_compute_subnetwork.vpc1_eu_subnet
      asia_subnet = google_compute_subnetwork.vpc1_asia_subnet
      us_subnet   = google_compute_subnetwork.vpc1_us_subnet
    }
    vpc2 = {
      eu_subnet   = google_compute_subnetwork.vpc2_eu_subnet
      asia_subnet = google_compute_subnetwork.vpc2_asia_subnet
      us_subnet   = google_compute_subnetwork.vpc2_us_subnet
    }
  }
  sensitive = true
}
