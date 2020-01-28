
# hub eu
#---------------------------------------------

# eu1

## onprem zone

resource "google_dns_managed_zone" "hub_eu1_onprem_zone" {
  provider    = google-beta
  project     = var.project_id_hub
  name        = "${var.hub.prefix}eu1-to-onprem"
  dns_name    = "onprem.lab."
  description = "--> dns proxy"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.hub.vpc_eu1.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = var.hub.eu1.proxy_ip
    }
  }
}

## local zones

resource "google_dns_managed_zone" "hub_eu1_zones" {
  provider    = google-beta
  project     = var.project_id_hub
  count       = length(var.hub_zones)
  name        = "${var.hub.prefix}eu1-${count.index}"
  dns_name    = element(var.hub_zones, count.index)
  description = "local zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.hub.vpc_eu1.self_link
    }
  }
}

## records

resource "google_dns_record_set" "hub_eu1_records" {
  project      = var.project_id_hub
  count        = length(var.hub_records)
  name         = element(var.hub_dns, count.index)
  type         = "A"
  ttl          = 300
  managed_zone = "${var.hub.prefix}eu1-${count.index}"
  rrdatas      = [element(var.hub_records, count.index)]

  depends_on = [google_dns_managed_zone.hub_eu1_zones]
}

## inbound dns policy

resource "google_dns_policy" "hub_eu1_inbound" {
  provider                  = google-beta
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}eu1-inbound"
  enable_inbound_forwarding = true

  networks {
    network_url = local.hub.vpc_eu1.self_link
  }
}

# peering: hub eu2 --> eu1
#---------------------------------------------

resource "google_dns_managed_zone" "eu2_to_eu1" {
  provider    = google-beta
  project     = var.project_id_hub
  name        = "${var.hub.prefix}eu2-to-eu1"
  dns_name    = "lab."
  description = "peering: eu2 to eu1"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.hub.vpc_eu2.self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.hub.vpc_eu1.self_link
    }
  }
}

# peering: hub asia1 --> eu1
#---------------------------------------------

resource "google_dns_managed_zone" "asia1_to_eu1" {
  provider    = google-beta
  project     = var.project_id_hub
  name        = "${var.hub.prefix}asia1-to-eu1"
  dns_name    = "lab."
  description = "peering: asia1 to eu1"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.hub.vpc_asia1.self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.hub.vpc_eu1.self_link
    }
  }
}

# peering: hub asia2 --> eu1
#---------------------------------------------

resource "google_dns_managed_zone" "asia2_to_eu1" {
  provider    = google-beta
  project     = var.project_id_hub
  name        = "${var.hub.prefix}asia2-to-eu1"
  dns_name    = "lab."
  description = "peering: asia2 to eu1"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.hub.vpc_asia2.self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.hub.vpc_eu1.self_link
    }
  }
}

# peering: hub us1 --> eu1
#---------------------------------------------

resource "google_dns_managed_zone" "us1_to_eu1" {
  provider    = google-beta
  project     = var.project_id_hub
  name        = "${var.hub.prefix}us1-to-eu1"
  dns_name    = "lab."
  description = "peering: us1 to eu1"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.hub.vpc_us1.self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.hub.vpc_eu1.self_link
    }
  }
}

# peering: hub us2 --> eu1
#---------------------------------------------

resource "google_dns_managed_zone" "us2_to_eu1" {
  provider    = google-beta
  project     = var.project_id_hub
  name        = "${var.hub.prefix}us2-to-eu1"
  dns_name    = "lab."
  description = "peering: us2 to eu1"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.hub.vpc_us2.self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.hub.vpc_eu1.self_link
    }
  }
}
