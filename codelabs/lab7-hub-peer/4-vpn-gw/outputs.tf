output "gateway" {
  value = {
    onprem = {
      ha_vpn_a = google_compute_ha_vpn_gateway.onprem_ha_vpn_a
      ha_vpn_b = google_compute_ha_vpn_gateway.onprem_ha_vpn_b
    }
    hub = {
      ha_vpn_a = google_compute_ha_vpn_gateway.hub_ha_vpn_a
      ha_vpn_b = google_compute_ha_vpn_gateway.hub_ha_vpn_b
    }
  }
}
