output "gateway" {
  value = {
    onprem = {
      ha_vpn = google_compute_ha_vpn_gateway.onprem_ha_vpn
    }
    hub = {
      ha_vpn = google_compute_ha_vpn_gateway.hub_ha_vpn
      vpn    = module.vpn_gw_hub.vpn.gateway
      vpn_ip = module.vpn_gw_hub.vpn.gateway_ip
    }
    spoke1 = {
      vpn    = module.vpn_gw_spoke1.vpn.gateway
      vpn_ip = module.vpn_gw_spoke1.vpn.gateway_ip
    }
  }
  sensitive = true
}
