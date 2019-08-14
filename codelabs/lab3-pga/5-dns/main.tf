
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
    path = "../3-instances/terraform.tfstate"
  }
}

locals {
  onprem = { network_self_link = data.terraform_remote_state.vpc.outputs.vpc.onprem.network.self_link }
  cloud  = { network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud.network.self_link }
}

# onprem
#---------------------------------------------

# queries for "onprem.lab." forwarded to unbound server

resource "google_dns_managed_zone" "onprem_to_onprem" {
  provider    = google-beta
  name        = "${var.onprem.prefix}to-onprem"
  dns_name    = "onprem.lab."
  description = "for *.lab, forward to onprem unbound server"
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

# queries for "lab." forwarded to onprem DNS proxy

resource "google_dns_managed_zone" "onprem_to_lab" {
  provider    = google-beta
  name        = "${var.onprem.prefix}to-lab"
  dns_name    = "lab."
  description = "for *.lab, forward to onprem DNS proxy"
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

# queries for "." forwarded to onprem unbound server

resource "google_dns_managed_zone" "onprem_to_unbound" {
  provider    = google-beta
  name        = "${var.onprem.prefix}to-unbound"
  dns_name    = "."
  description = "for all (.), forward to onprem unbound server"
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

# cloud
#---------------------------------------------

# queries for "cloud.lab" forwarded to metadata server

resource "google_dns_managed_zone" "cloud_to_cloud" {
  provider    = google-beta
  name        = "${var.cloud.prefix}to-cloud"
  dns_name    = "cloud.lab."
  description = "cloud.lab local private zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud.network_self_link
    }
  }
}

# A Record for cloud VM

resource "google_dns_record_set" "cloud_vm_record" {
  name = "vm.cloud.lab."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.cloud_to_cloud.name
  rrdatas      = [var.cloud.vm_ip]
}

# queries for "onprem.lab" forwarded to cloud DNS proxy

resource "google_dns_managed_zone" "cloud_to_onprem" {
  provider    = google-beta
  name        = "${var.cloud.prefix}to-onprem"
  dns_name    = "onprem.lab."
  description = "for onprem.lab, forward to cloud DNS proxy"
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

resource "google_dns_policy" "cloud_inbound" {
  provider                  = google-beta
  name                      = "${var.cloud.prefix}inbound"
  enable_inbound_forwarding = true

  networks {
    network_url = local.cloud.network_self_link
  }
}

# googleapis.com. zone

resource "google_dns_managed_zone" "googleapis" {
  provider    = google-beta
  name        = "${var.cloud.prefix}googleapis"
  dns_name    = "googleapis.com."
  description = "googleapis private zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud.network_self_link
    }
  }
}

# gcr.io zone

resource "google_dns_managed_zone" "private_gcr_io" {
  provider    = "google-beta"
  name        = "${var.cloud.prefix}private-gcr-io"
  dns_name    = "gcr.io."
  description = "gcr.io private zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud.network_self_link
    }
  }
}

# restricted.googleapis.com is used for APIs for VPC SC

resource "google_dns_record_set" "restricted_googleapis_cname" {
  count        = length(var.restricted_apis)
  name         = "${element(var.restricted_apis, count.index)}.${google_dns_managed_zone.googleapis.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.googleapis.name
  rrdatas      = ["restricted.${google_dns_managed_zone.googleapis.dns_name}"]
}

resource "google_dns_record_set" "restricted_googleapis" {
  name = "restricted.${google_dns_managed_zone.googleapis.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.googleapis.name

  rrdatas = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]
}

# restricted.googleapis.com is used for gcr.io

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

# private.googleapis.com is used for all other googleapis

resource "google_dns_record_set" "private_googleapis_cname" {
  name         = "*.${google_dns_managed_zone.googleapis.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.googleapis.name
  rrdatas      = ["private.${google_dns_managed_zone.googleapis.dns_name}"]
}

resource "google_dns_record_set" "private_googleapis" {
  name = "private.${google_dns_managed_zone.googleapis.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.googleapis.name

  rrdatas = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11",
  ]
}
