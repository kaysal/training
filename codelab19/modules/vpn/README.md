# VPN Tunnel

This modules creates:
- A Google VPN Gateway
- An optional VPN GW IP address if not supplied
- Tunnels connecting the gateway to defined peers
- Dynamic routes with cloud router

## Requirements

## Example Usage

```hcl
module "vpn-aws-eu-w1-vpc1" {
  source        = "github.com/kaysal/modules.git//gcp/vpn"
  project_id    = var.project_id
  network       = google_compute_network.vpc.name
  region        = "europe-west1"
  gateway_name  = "vpn-gw-eu-w1"
  gateway_ip    = google_compute_address.vpn_gw_ip[0].address
  shared_secret = var.psk
  cr_name       = google_compute_router.cr_eu_w1.name
  ike_version   = 1

  tunnels = [
    {
      tunnel_name               = "tunnel-1"
      peer_ip                   = var.peer_ip
      peer_asn                  = var.peer_asn
      cr_bgp_session_range      = "169.254.100.1/30"
      remote_bgp_session_ip     = "169.254.200.2"
      advertised_route_priority = 100
    },
    {
      tunnel_name               = "tunnel-1"
      peer_ip                   = var.peer_ip
      peer_asn                  = var.peer_asn
      cr_bgp_session_range      = "169.254.100.5/30"
      remote_bgp_session_ip     = "169.254.200.6"
      advertised_route_priority = 100
    },
  ]
}
```

Then perform the following commands on the root folder:

- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure

## Inputs


## Outputs
See `/outputs.tf` file for the outputs generated using `terraform output` command
