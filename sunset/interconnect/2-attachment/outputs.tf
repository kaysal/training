output "attachment" {
  value = {
    prod_router1      = google_compute_router.prod_router1
    prod_router2      = google_compute_router.prod_router2
    prod_ic3_vlan_100 = google_compute_interconnect_attachment.prod_ic3_vlan_100
    prod_ic4_vlan_100 = google_compute_interconnect_attachment.prod_ic4_vlan_100
  }
  sensitive = true
}
