output "networks" {
  value = {
    onprem = google_compute_network.onprem_vpc
    hub = {
      eu1    = google_compute_network.hub_eu1_vpc
      eu2    = google_compute_network.hub_eu2_vpc
      eu1x   = google_compute_network.hub_eu1_vpcx
      eu2x   = google_compute_network.hub_eu2_vpcx
      asia1  = google_compute_network.hub_asia1_vpc
      asia2  = google_compute_network.hub_asia2_vpc
      asia1x = google_compute_network.hub_asia1_vpcx
      asia2x = google_compute_network.hub_asia2_vpcx
      us1    = google_compute_network.hub_us1_vpc
      us2    = google_compute_network.hub_us2_vpc
      us1x   = google_compute_network.hub_us1_vpcx
      us2x   = google_compute_network.hub_us2_vpcx
    }
    svc = google_compute_network.svc_vpc
  }
  sensitive = true
}

output "cidrs" {
  value = {
    onprem = {
      eu_cidr   = google_compute_subnetwork.onprem_eu_cidr
      asia_cidr = google_compute_subnetwork.onprem_asia_cidr
      us_cidr   = google_compute_subnetwork.onprem_us_cidr
    }
    hub = {
      eu1_cidr    = google_compute_subnetwork.hub_eu1_cidr
      eu1_cidrx   = google_compute_subnetwork.hub_eu1_cidrx
      eu2_cidr    = google_compute_subnetwork.hub_eu2_cidr
      eu2_cidrx   = google_compute_subnetwork.hub_eu2_cidrx
      asia1_cidr  = google_compute_subnetwork.hub_asia1_cidr
      asia1_cidrx = google_compute_subnetwork.hub_asia1_cidrx
      asia2_cidr  = google_compute_subnetwork.hub_asia2_cidr
      asia2_cidrx = google_compute_subnetwork.hub_asia2_cidrx
      us1_cidr    = google_compute_subnetwork.hub_us1_cidr
      us1_cidrx   = google_compute_subnetwork.hub_us1_cidrx
      us2_cidr    = google_compute_subnetwork.hub_us2_cidr
      us2_cidrx   = google_compute_subnetwork.hub_us2_cidrx
    }
    svc = {
      eu1_cidr     = google_compute_subnetwork.svc_eu1_cidr
      eu1_gke_cidr = google_compute_subnetwork.svc_eu1_gke_cidr
      eu2_cidr     = google_compute_subnetwork.svc_eu2_cidr
      asia1_cidr   = google_compute_subnetwork.svc_asia1_cidr
      asia2_cidr   = google_compute_subnetwork.svc_asia2_cidr
      us1_cidr     = google_compute_subnetwork.svc_us1_cidr
      us1_gke_cidr = google_compute_subnetwork.svc_us1_gke_cidr
      us2_cidr     = google_compute_subnetwork.svc_us2_cidr
    }
  }
  sensitive = true
}
