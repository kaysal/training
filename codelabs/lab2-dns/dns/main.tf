
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "instance" {
  backend = "local"

  config = {
    path = "../instances/terraform.tfstate"
  }
}

locals {
  onprem = {
    prefix            = "lab2-onprem-"
    region            = "europe-west1"
    dns_proxy_fwd_ip  = "192.168.2.1"
    dns_unbound_ip    = "172.16.1.99"
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.onprem.network.self_link
  }

  cloud = {
    prefix                = "lab2-cloud-"
    region                = "europe-west1"
    dns_proxy_fwd_ip      = "192.168.1.1"
    dns_policy_inbound_ip = "10.10.1.3"
    vm_ip                 = data.terraform_remote_state.instance.outputs.cloud_vm.network_interface.0.network_ip
    network_self_link     = data.terraform_remote_state.vpc.outputs.vpc.cloud.network.self_link
  }
}

# onprem
#---------------------------------------------

# private zone to allow all GCE VM's use the
# unbound server to query the on-premises zone
# *.onprem.lab

resource "google_dns_managed_zone" "onprem_forward_to_unbound" {
  provider    = google-beta
  name        = "${local.onprem.prefix}forward-to-unbound"
  dns_name    = "."
  description = "default local resolver -> unbound"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.onprem.network_self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = local.onprem.dns_unbound_ip
    }
  }
}

# resolving cloud.lab via unbound gives error
# due to interaction of unbound with metadat server
# so cloud.lab is resolved via remote cloud inbound
# dns endpoint

resource "google_dns_managed_zone" "onprem_forward_to_cloud" {
  provider    = google-beta
  name        = "${local.onprem.prefix}forward-to-cloud"
  dns_name    = "cloud.lab."
  description = "resolver for cloud.lab -> cloud dns inbound IP"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.onprem.network_self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = local.onprem.dns_proxy_fwd_ip
    }
  }
}

/*
# inbound dns policy
# overrides zone configurations

resource "google_dns_policy" "onprem_inbound_policy" {
  provider                  = google-beta
  name                      = "${local.onprem.prefix}inbound-policy"
  enable_inbound_forwarding = true

  networks {
    network_url = local.onprem.network_self_link
  }

  alternative_name_server_config {
    target_name_servers {
      ipv4_address = local.onprem.dns_unbound_ip
    }
  }
}
*/

# cloud
#---------------------------------------------

# private zone for cloud VPC

resource "google_dns_managed_zone" "cloud_local_zone" {
  provider    = google-beta
  name        = "${local.cloud.prefix}local-zone"
  dns_name    = "cloud.lab."
  description = "default local resolver -> metadata server"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud.network_self_link
    }
  }
}

# A Record for Cloud VM

resource "google_dns_record_set" "cloud_vm_record" {
  name = "vm.cloud.lab."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.cloud_local_zone.name
  rrdatas      = [local.cloud.vm_ip]
}

# private on-premises zone on cloud VPC
# forwarded to on-premises name server

resource "google_dns_managed_zone" "cloud_forward_to_onprem" {
  provider    = google-beta
  name        = "${local.cloud.prefix}forward-to-onprem"
  dns_name    = "onprem.lab."
  description = "resolver for onprem.lab -> onprem NS"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud.network_self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = local.cloud.dns_proxy_fwd_ip
    }
  }
}

# inbound dns policy

resource "google_dns_policy" "cloud_inbound_policy" {
  provider                  = google-beta
  name                      = "${local.cloud.prefix}inbound-policy"
  enable_inbound_forwarding = true

  networks {
    network_url = local.cloud.network_self_link
  }
}
