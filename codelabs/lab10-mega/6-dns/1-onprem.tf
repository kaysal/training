
# onprem
#---------------------------------------------

# queries forwarded to unbound server

resource "google_dns_managed_zone" "onprem_zones" {
  provider    = google-beta
  project     = var.project_id_onprem
  count       = length(var.onprem_zones)
  name        = "${var.onprem.prefix}${count.index}"
  dns_name    = element(var.onprem_zones, count.index)
  description = "--> ${element(var.onprem_forward_ns, count.index)}"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.onprem.vpc.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = element(var.onprem_forward_ns, count.index)
    }
  }
}
