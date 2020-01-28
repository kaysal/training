output "gateway" {
  value = {
    onprem = {
      ha_vpn_a = google_compute_ha_vpn_gateway.onprem_ha_vpn_a
      ha_vpn_b = google_compute_ha_vpn_gateway.onprem_ha_vpn_b
    }
    hub = {
      ha_vpn_a = google_compute_ha_vpn_gateway.hub_ha_vpn_a
      ha_vpn_b = google_compute_ha_vpn_gateway.hub_ha_vpn_b
      vpn_a    = module.vpn_gw_hub_a.vpn.gateway
      vpn_b    = module.vpn_gw_hub_b.vpn.gateway
      vpn_a_ip = module.vpn_gw_hub_a.vpn.gateway_ip
      vpn_b_ip = module.vpn_gw_hub_b.vpn.gateway_ip
    }
    spoke1 = {
      vpn_a    = module.vpn_gw_spoke1_a.vpn.gateway
      vpn_b    = module.vpn_gw_spoke1_b.vpn.gateway
      vpn_a_ip = module.vpn_gw_spoke1_a.vpn.gateway_ip
      vpn_b_ip = module.vpn_gw_spoke1_b.vpn.gateway_ip
    }
    spoke2 = {
      vpn_a    = module.vpn_gw_spoke2_a.vpn.gateway
      vpn_b    = module.vpn_gw_spoke2_b.vpn.gateway
      vpn_a_ip = module.vpn_gw_spoke2_a.vpn.gateway_ip
      vpn_b_ip = module.vpn_gw_spoke2_b.vpn.gateway_ip
    }
  }
}
