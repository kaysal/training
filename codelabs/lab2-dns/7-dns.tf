# onprem
#---------------------------------------------

# private zone to allow all GCE VM's use the
# unbound server to query the on-premises zone
# *.onprem.lab

resource "google_dns_managed_zone" "unbound_dns" {
  provider    = google-beta
  name        = "unbound-dns"
  dns_name    = "."
  description = "route all onprem VPC queries to local unbound dns server"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = module.vpc_onprem.network.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = local.onprem.unbound_ip
    }
  }

  depends_on = [
    module.vm_onprem,
    module.ns_onprem,
    module.vm_cloud,
  ]
}

# inbound dns policy

resource "google_dns_policy" "onprem_inbound" {
  provider                  = google-beta
  name                      = "onprem-inbound"
  enable_inbound_forwarding = true

  networks {
    network_url = module.vpc_onprem.network.self_link
  }

  alternative_name_server_config {
    target_name_servers {
      ipv4_address = local.onprem.unbound_ip
    }
  }

  depends_on = [
    module.vm_onprem,
    module.ns_onprem,
    module.vm_cloud,
  ]
}
}

resource "google_dns_managed_zone" "cloud_zone_forward" {
  provider    = google-beta
  name        = "cloud-zone-forward"
  dns_name    = "cloud.lab."
  description = "dns queries to cloud zone routed through unbound to forward to Cloud DNS"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = module.vpc_onprem.network.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = local.onprem.unbound_ip
    }
  }

  depends_on = [
    module.vm_onprem,
    module.ns_onprem,
    module.vm_cloud,
  ]
}

# cloud
#---------------------------------------------

# private zone for cloud VPC

resource "google_dns_managed_zone" "cloud_zone_local" {
  provider    = google-beta
  name        = "cloud-zone-local"
  dns_name    = "cloud.lab."
  description = "local private zone for Cloud VPC"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = module.vpc_cloud.network.self_link
    }
  }
}

# A Record for Cloud VM

resource "google_dns_record_set" "vm_cloud_zone_record" {
  name = "vm.cloud.lab."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.cloud_zone_local.name
  rrdatas      = [module.vm_cloud.instance.network_interface.0.network_ip]
}

# private on-premises zone on cloud VPC
# forwarded to on-premises name server

resource "google_dns_managed_zone" "onprem_zone_forward" {
  provider    = google-beta
  name        = "onprem-zone-forward"
  dns_name    = "onprem.lab."
  description = "route on-premises zone queries to on-premises unbound dns server"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = module.vpc_cloud.network.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = local.cloud.dns_nat_ip
    }
  }
}


# inbound dns policy

resource "google_dns_policy" "cloud_inbound" {
  provider                  = google-beta
  name                      = "cloud-inbound"
  enable_inbound_forwarding = true

  networks {
    network_url = module.vpc_cloud.network.self_link
  }

  depends_on = [module.vm_cloud]
}
