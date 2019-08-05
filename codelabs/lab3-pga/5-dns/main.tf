
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
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "ip" {
  backend = "local"

  config = {
    path = "../2-instances/terraform.tfstate"
  }
}

locals {
  onprem = {
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.onprem.network.self_link
  }

  cloud = {
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
  name        = "${var.onprem.prefix}forward-to-unbound"
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
      ipv4_address = var.onprem.dns_unbound_ip
    }
  }
}

# resolving cloud.lab via unbound gives error
# due to interaction of unbound with metadat server
# so cloud.lab is resolved via remote cloud inbound
# dns endpoint

resource "google_dns_managed_zone" "onprem_forward_to_cloud" {
  provider    = google-beta
  name        = "${var.onprem.prefix}forward-to-cloud"
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
      ipv4_address = var.onprem.dns_proxy_ip
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
  name        = "${var.cloud.prefix}local-zone"
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
  rrdatas      = [var.cloud.vm_ip]
}

# private on-premises zone on cloud VPC
# forwarded to on-premises name server

resource "google_dns_managed_zone" "cloud_forward_to_onprem" {
  provider    = google-beta
  name        = "${var.cloud.prefix}forward-to-onprem"
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
      ipv4_address = var.cloud.dns_proxy_ip
    }
  }
}

# inbound dns policy

resource "google_dns_policy" "cloud_inbound_policy" {
  provider                  = google-beta
  name                      = "${var.cloud.prefix}inbound-policy"
  enable_inbound_forwarding = true

  networks {
    network_url = local.cloud.network_self_link
  }
}

# private google access
# googleapis.com

resource "google_dns_managed_zone" "private_googleapis" {
  provider    = google-beta
  name        = "${var.cloud.prefix}private-googleapis"
  dns_name    = "googleapis.com."
  description = "private zone for googleapis"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud.network_self_link
    }
  }
}

resource "google_dns_record_set" "googleapis_cname" {
  name = "*.${google_dns_managed_zone.private_googleapis.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = google_dns_managed_zone.private_googleapis.name
  rrdatas      = ["restricted.${google_dns_managed_zone.private_googleapis.dns_name}"]
}

resource "google_dns_record_set" "restricted_googleapis" {
  name = "restricted.${google_dns_managed_zone.private_googleapis.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.private_googleapis.name

  rrdatas = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]
}

# private google access
# gcr.io

resource "google_dns_managed_zone" "private_gcr_io" {
  provider    = "google-beta"
  name        = "${var.cloud.prefix}private-gcr-io"
  dns_name    = "gcr.io."
  description = "private zone for gcr.io"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud.network_self_link
    }
  }
}

resource "google_dns_record_set" "gcr_io_cname" {
  name = "*.gcr.io."
  type = "CNAME"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.private_gcr_io.name}"
  rrdatas      = ["gcr.io."]
}

resource "google_dns_record_set" "restricted_gcr_io" {
  name = "gcr.io."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.private_gcr_io.name

  rrdatas = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]
}
