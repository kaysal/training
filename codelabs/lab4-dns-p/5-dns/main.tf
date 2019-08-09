
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
  onprem = {
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.onprem.network.self_link
  }
  cloud1 = {
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud1.network.self_link
  }
  cloud2 = {
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud2.network.self_link
  }
  cloud3 = {
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud3.network.self_link
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

# resolving cloud1.lab via unbound gives error
# due to interaction of unbound with metadat server
# so cloud1.lab is resolved via the remote cloud1 inbound
# dns endpoint

resource "google_dns_managed_zone" "onprem_forward_to_cloud" {
  provider    = google-beta
  name        = "${var.onprem.prefix}forward-to-cloud"
  dns_name    = "cloud1.lab."
  description = "resolver for cloud1.lab -> cloud1 dns inbound IP"
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

# cloud1
#---------------------------------------------

# private zone for cloud1 VPC

resource "google_dns_managed_zone" "cloud1_local_zone" {
  provider    = google-beta
  name        = "${var.cloud1.prefix}local-zone"
  dns_name    = "cloud1.lab."
  description = "default local resolver -> metadata server"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud1.network_self_link
    }
  }
}

# A Record for Cloud1 VM

resource "google_dns_record_set" "cloud1_vm_record" {
  name = "vm.cloud1.lab."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.cloud1_local_zone.name
  rrdatas      = [var.cloud1.vm_ip]
}

# private on-premises zone on cloud1 VPC
# forwarded to on-premises name server

resource "google_dns_managed_zone" "cloud1_forward_to_onprem" {
  provider    = google-beta
  name        = "${var.cloud1.prefix}forward-to-onprem"
  dns_name    = "onprem.lab."
  description = "resolver for onprem.lab -> onprem NS"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud1.network_self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = var.cloud1.dns_proxy_ip
    }
  }
}

# peering zone to cloud2.lab.

resource "google_dns_managed_zone" "cloud1_peering_zone_to_cloud2" {
  provider    = google-beta
  name        = "${var.cloud2.prefix}peering-to-cloud2"
  dns_name    = "cloud2.lab."
  description = "peering zone to cloud2.lab."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud1.network_self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.cloud2.network_self_link
    }
  }
}

# peering zone to cloud3.lab.

resource "google_dns_managed_zone" "cloud1_peering_zone_to_cloud3" {
  provider    = google-beta
  name        = "${var.cloud2.prefix}peering-to-cloud3"
  dns_name    = "cloud3.lab."
  description = "peering zone to cloud3.lab."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud1.network_self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.cloud3.network_self_link
    }
  }
}

# inbound dns policy

resource "google_dns_policy" "cloud1_inbound_policy" {
  provider                  = google-beta
  name                      = "${var.cloud1.prefix}inbound-policy"
  enable_inbound_forwarding = true

  networks {
    network_url = local.cloud1.network_self_link
  }
}

# private google access
# www.googleapis.com

resource "google_dns_managed_zone" "www_googleapis" {
  provider    = google-beta
  name        = "${var.cloud1.prefix}www-googleapis"
  dns_name    = "www.googleapis.com."
  description = "private zone for wwww.googleapis.com"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud1.network_self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = "8.8.8.8"
    }

    target_name_servers {
      ipv4_address = "8.8.4.4"
    }
  }
}

# private google access
# *.googleapis.com

resource "google_dns_managed_zone" "private_googleapis" {
  provider    = google-beta
  name        = "${var.cloud1.prefix}private-googleapis"
  dns_name    = "googleapis.com."
  description = "private zone for googleapis"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud1.network_self_link
    }
  }
}

resource "google_dns_record_set" "googleapis_cname" {
  count        = length(var.apis)
  name         = "${element(var.apis, count.index)}.${google_dns_managed_zone.private_googleapis.dns_name}"
  type         = "CNAME"
  ttl          = 300
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
  name        = "${var.cloud1.prefix}private-gcr-io"
  dns_name    = "gcr.io."
  description = "private zone for gcr.io"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud1.network_self_link
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


# cloud2
#---------------------------------------------

# private zone for cloud2 VPC

resource "google_dns_managed_zone" "cloud2_local_zone" {
  provider    = google-beta
  name        = "${var.cloud2.prefix}local-zone"
  dns_name    = "cloud2.lab."
  description = "default local resolver -> metadata server"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud2.network_self_link
    }
  }
}

# A Record for cloud2 VM

resource "google_dns_record_set" "cloud2_vm_record" {
  name = "vm.cloud2.lab."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.cloud2_local_zone.name
  rrdatas      = [var.cloud2.vm_ip]
}

# peering zone to lab.

resource "google_dns_managed_zone" "cloud2_peering_zone" {
  provider    = google-beta
  name        = "${var.cloud2.prefix}peering-zone"
  dns_name    = "lab."
  description = "peering zone to lab."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud2.network_self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.cloud1.network_self_link
    }
  }
}

# cloud3
#---------------------------------------------

# private zone for cloud3 VPC

resource "google_dns_managed_zone" "cloud3_local_zone" {
  provider    = google-beta
  name        = "${var.cloud3.prefix}local-zone"
  dns_name    = "cloud3.lab."
  description = "default local resolver -> metadata server"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud3.network_self_link
    }
  }
}

# A Record for cloud3 VM

resource "google_dns_record_set" "cloud3_vm_record" {
  name = "vm.cloud3.lab."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.cloud3_local_zone.name
  rrdatas      = [var.cloud3.vm_ip]
}

# peering zone to lab.

resource "google_dns_managed_zone" "cloud3_peering_zone" {
  provider    = google-beta
  name        = "${var.cloud3.prefix}peering-zone"
  dns_name    = "lab."
  description = "peering zone to lab."
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud3.network_self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.cloud1.network_self_link
    }
  }
}
