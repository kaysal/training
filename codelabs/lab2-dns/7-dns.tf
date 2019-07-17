resource "google_dns_managed_zone" "unbound_dns" {
  provider    = google-beta
  name        = "${local.onprem.prefix}unbound-dns"
  dns_name    = "onprem.lab."
  description = "route all queries to local unbound dns server"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = module.vpc_onprem.network.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = "172.16.1.99"
    }
  }
}
