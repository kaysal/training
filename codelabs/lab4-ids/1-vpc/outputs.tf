output "networks" {
  value = {
    vpc1 = google_compute_network.vpc1
    vpc2 = google_compute_network.vpc2
  }
  sensitive = true
}

output "subnets" {
  value = {
    vpc1 = {
      subnet_collector = google_compute_subnetwork.vpc1_subnet_collector
      subnet_mirror    = google_compute_subnetwork.vpc1_subnet_mirror
    }
    vpc2 = {
      subnet_mirror = google_compute_subnetwork.vpc2_subnet_mirror
    }
  }
  sensitive = true
}
