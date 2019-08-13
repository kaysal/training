# Classic VPN Tunnel

This modules creates a classic VPN gateway and tunnels

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| advertised\_route\_priority | Please enter the priority for the advertised route to BGP peer(default is 100) | string | `"100"` | no |
| bgp\_cr\_session\_range | Please enter the cloud-router interface IP/Session IP | list | n/a | yes |
| bgp\_remote\_session\_range | Please enter the remote environments BGP Session IP | list | n/a | yes |
| cr\_name | The name of cloud router for BGP routing | string | n/a | yes |
| gateway\_ip | The IP of VPN gateway | string | n/a | yes |
| gateway\_name | The name of VPN gateway | string | n/a | yes |
| ike\_version | Please enter the IKE version used by this tunnel (default is IKEv2) | string | `"2"` | no |
| network | The name of VPC being created | string | n/a | yes |
| peer\_asn | Please enter the ASN of the BGP peer that cloud router will use | list | n/a | yes |
| peer\_ips | IP address of remote-peer/gateway | list | n/a | yes |
| prefix | Prefix appended before resource names | string | n/a | yes |
| project\_id | The ID of the project where this VPC will be created | string | n/a | yes |
| region | The region in which you want to create the VPN gateway | string | n/a | yes |
| shared\_secret | Please enter the shared secret/pre-shared key | string | n/a | yes |
| tunnel\_count | The number of tunnels from each VPN gw (default is 1) | string | `"1"` | no |
| tunnel\_name\_prefix | The optional custom name of VPN tunnel being created | string | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpn\_tunnels | The VPN tunnel attributes |

## Example Usage

```hcl

resource "google_compute_router" "router" {
  name    = "router"
  network = var.network
  region  = var.region

  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

resource "google_compute_address" "vpn_gw_address" {
  name    = "vpn-gw-address"
  region  = "us-central1"
}

# VPNGW and Tunnel in US Centra1
module "vpc_demo_vpn_us_c1" {
  source                   = "./modules/vpn-classic"
  project_id               = var.project_id
  prefix                   = "prefix-"
  network                  = var.network
  region                   = "us-central1"
  gateway_name             = "vpn-gateway"
  gateway_ip               = google_compute_address.vpn_gw_address.address
  tunnel_name_prefix       = "tunnel-"
  shared_secret            = var.psk
  tunnel_count             = 1
  cr_name                  = google_compute_router.router.name
  peer_asn                 = [64515]
  ike_version              = 2
  peer_ips                 = [var.peer_ip]
  bgp_cr_session_range     = ["169.254.100.1/30"]
  bgp_remote_session_range = ["169.254.100.2"]
}
```
