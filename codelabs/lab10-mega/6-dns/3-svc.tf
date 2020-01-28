
# peering zone to eu1

resource "google_dns_managed_zone" "svc_to_eu1" {
  provider    = google-beta
  project     = var.project_id_svc
  name        = "${var.hub.prefix}svc-to-eu1"
  dns_name    = "lab."
  description = "peering: svc to eu1"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.svc.vpc.self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.hub.vpc_eu1.self_link
    }
  }
}
