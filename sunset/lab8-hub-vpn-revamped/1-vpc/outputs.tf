
output "vpc" {
  onprem = {
    network        = google_compute_network.onprem_vpc
    belgium_subnet = google_compute_subnetwork.onprem_belgium
    london_subnet  = google_compute_subnetwork.onprem_london
  }
  hub = {
    network        = google_compute_network.hub_vpc
    belgium_subnet = google_compute_subnetwork.hub_belgium
    london_subnet  = google_compute_subnetwork.hub_london
  }
  spoke1 = {
    network        = google_compute_network.spoke1_vpc
    belgium_subnet = google_compute_subnetwork.spoke1_belgium
    london_subnet  = google_compute_subnetwork.spoke1_london
  }
  spoke2 = {
    network        = google_compute_network.spoke2_vpc
    belgium_subnet = google_compute_subnetwork.spoke2_belgium
    london_subnet  = google_compute_subnetwork.spoke2_london
  }
}
