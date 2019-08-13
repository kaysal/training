# HA VPN Tunnel

This modules creates a HA VPN from GCP to GCP

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| advertised\_route\_priority | Priority for the advertised route to BGP peer (default is 100) | string | `"100"` | no |
| ike\_version | IKE version used by the tunnel (default is IKEv2) | string | `"2"` | no |
| network | The name of VPC being created | string | n/a | yes |
| peer\_gcp\_gateway | self_link of peer GCP VPN gateway | string | n/a | yes |
| project\_id | project id where resources belong to | string | n/a | yes |
| region | The VPN gateway region | string | n/a | yes |
| router | The name of cloud router for BGP routing | string | n/a | yes |
| session\_config | The list of configurations of the vpn tunnels and bgp sessions being created | list | n/a | yes |
| shared\_secret | VPN tunnel pre-shared key | string | n/a | yes |
| vpn\_gateway | self_link of HA VPN gateway | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| router\_interface | The router interface names |
| vpn\_gateway | The Gateway resource with all attributes |
| vpn\_tunnels | The VPN tunnel resource and with all attributes |

## Example Usage

```hcl
# cloud router

resource "google_compute_router" "router" {
  name    = "router"
  network = var.network
  region  = var.region

  bgp {
    asn               = 65001
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# vpn gateway

resource "google_compute_ha_vpn_gateway" "vpn_gw" {
  provider = "google-beta"
  region   = var.region
  name     = "vpn-gw"
  network  = var.network
}

# vpn tunnel

module "vpn_tunnel" {
  source           = "../modules/vpn-ha-gcp"
  project_id       = var.project_id
  network          = var.network
  region           = var.region
  vpn_gateway      = google_compute_ha_vpn_gateway.vpn_gw.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.hub_vpn_gw.self_link
  shared_secret    = var.psk
  router           = google_compute_router.router.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "tunnel-1"
      peer_asn                  = 65002
      cr_bgp_session_range      = "169.254.100.1/30"
      remote_bgp_session_ip     = "169.254.100.2"
      advertised_route_priority = 100
    },
    {
      session_name              = "tunnel-2"
      peer_asn                  = 65002
      cr_bgp_session_range      = "169.254.100.5/30"
      remote_bgp_session_ip     = "169.254.100.6"
      advertised_route_priority = 100
    },
  ]
}
```
