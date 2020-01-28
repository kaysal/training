output "networks" {
  value = {
    hub = {
      network = google_compute_network.hub_vpc
    }
    spoke1 = {
      network = google_compute_network.spoke1_vpc
    }
    spoke2 = {
      network = google_compute_network.spoke2_vpc
    }
  }
  sensitive = true
}

output "cidrs" {
  value = {
    hub = {
      eu_subnet   = google_compute_subnetwork.hub_eu_subnet
      asia_subnet = google_compute_subnetwork.hub_asia_subnet
      us_subnet   = google_compute_subnetwork.hub_us_subnet
    }
    spoke1 = {
      eu_subnet   = google_compute_subnetwork.spoke1_eu_subnet
      asia_subnet = google_compute_subnetwork.spoke1_asia_subnet
      us_subnet   = google_compute_subnetwork.spoke1_us_subnet
    }
    spoke2 = {
      eu_subnet   = google_compute_subnetwork.spoke2_eu_subnet
      asia_subnet = google_compute_subnetwork.spoke2_asia_subnet
    }
  }
  sensitive = true
}
