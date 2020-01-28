
provider "google" {}

provider "google-beta" {}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "router" {
  backend = "local"

  config = {
    path = "../3-router/terraform.tfstate"
  }
}

data "terraform_remote_state" "gateway" {
  backend = "local"

  config = {
    path = "../4-vpn-gw/terraform.tfstate"
  }
}

locals {
  onprem = {
    vpc = data.terraform_remote_state.vpc.outputs.networks.onprem
  }
  hub = {
    vpc_eu1   = data.terraform_remote_state.vpc.outputs.networks.hub.eu1
    vpc_eu2   = data.terraform_remote_state.vpc.outputs.networks.hub.eu2
    vpc_asia1 = data.terraform_remote_state.vpc.outputs.networks.hub.asia1
    vpc_asia2 = data.terraform_remote_state.vpc.outputs.networks.hub.asia2
    vpc_us1   = data.terraform_remote_state.vpc.outputs.networks.hub.us1
    vpc_us2   = data.terraform_remote_state.vpc.outputs.networks.hub.us2
  }
  svc = {
    vpc = data.terraform_remote_state.vpc.outputs.networks.svc
  }
}

# onprem
#---------------------------------------------

# queries forwarded to unbound server

resource "google_dns_managed_zone" "onprem_zones" {
  provider    = google-beta
  project     = var.project_id_onprem
  count       = length(var.onprem_zones)
  name        = "${var.onprem.prefix}${count.index}"
  dns_name    = "${element(var.onprem_zones, count.index)}"
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
  dns_name    = "${element(var.hub_zones, count.index)}"
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

# svc
#---------------------------------------------

# peering zone to eu

resource "google_dns_managed_zone" "svc_to_eu1" {
  provider    = google-beta
  project     = var.project_id_svc
  name        = "${var.svc.prefix}svc-to-eu1"
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
