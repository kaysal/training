output "networks" {
  value = {
    onprem = {
      network = google_compute_network.onprem_vpc
    }
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
    onprem = {
      subnet1 = google_compute_subnetwork.onprem_subnet1
      subnet2 = google_compute_subnetwork.onprem_subnet2
      subnet3 = google_compute_subnetwork.onprem_subnet3
    }
    hub = {
      subnet1 = google_compute_subnetwork.hub_subnet1
      subnet2 = google_compute_subnetwork.hub_subnet2
    }
    spoke1 = {
      subnet1 = google_compute_subnetwork.spoke1_subnet1
      subnet2 = google_compute_subnetwork.spoke1_subnet2
    }
    spoke2 = {
      subnet1 = google_compute_subnetwork.spoke2_subnet1
      subnet2 = google_compute_subnetwork.spoke2_subnet2
    }
  }
  sensitive = true
}
