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
      subnet_eu   = google_compute_subnetwork.hub_subnet_eu
      subnet_asia = google_compute_subnetwork.hub_subnet_asia
      subnet_us   = google_compute_subnetwork.hub_subnet_us
    }
    spoke1 = {
      subnet_eu   = google_compute_subnetwork.spoke1_subnet_eu
      subnet_asia = google_compute_subnetwork.spoke1_subnet_asia
      subnet_us   = google_compute_subnetwork.spoke1_subnet_us
    }
    spoke2 = {
      subnet_eu   = google_compute_subnetwork.spoke2_subnet_eu
      subnet_asia = google_compute_subnetwork.spoke2_subnet_asia
      subnet_us   = google_compute_subnetwork.spoke2_subnet_us
    }
  }
  sensitive = true
}
