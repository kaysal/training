output "gateway" {
  value = {
    onprem = {
      vpn_eu      = module.vpn_gw_onprem_eu.vpn.gateway
      vpn_asia    = module.vpn_gw_onprem_asia.vpn.gateway
      vpn_us      = module.vpn_gw_onprem_us.vpn.gateway
      vpn_eu_ip   = module.vpn_gw_onprem_eu.vpn.gateway_ip
      vpn_asia_ip = module.vpn_gw_onprem_asia.vpn.gateway_ip
      vpn_us_ip   = module.vpn_gw_onprem_us.vpn.gateway_ip
    }
    hub = {
      vpn_eu1      = module.vpn_gw_hub_eu1.vpn.gateway
      vpn_eu2      = module.vpn_gw_hub_eu2.vpn.gateway
      vpn_asia1    = module.vpn_gw_hub_asia1.vpn.gateway
      vpn_asia2    = module.vpn_gw_hub_asia2.vpn.gateway
      vpn_us1      = module.vpn_gw_hub_us1.vpn.gateway
      vpn_us2      = module.vpn_gw_hub_us2.vpn.gateway
      vpn_eu1_ip   = module.vpn_gw_hub_eu1.vpn.gateway_ip
      vpn_eu2_ip   = module.vpn_gw_hub_eu2.vpn.gateway_ip
      vpn_asia1_ip = module.vpn_gw_hub_asia1.vpn.gateway_ip
      vpn_asia2_ip = module.vpn_gw_hub_asia2.vpn.gateway_ip
      vpn_us1_ip   = module.vpn_gw_hub_us1.vpn.gateway_ip
      vpn_us2_ip   = module.vpn_gw_hub_us2.vpn.gateway_ip
    }
  }
  sensitive = true
}
