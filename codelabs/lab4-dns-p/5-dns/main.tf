
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
  onprem = {network_self_link = data.terraform_remote_state.vpc.outputs.vpc.onprem.network.self_link}
  cloud1 = {network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud1.network.self_link}
  cloud2 = {network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud2.network.self_link}
  cloud3 = {network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud3.network.self_link}
}

# onprem
#---------------------------------------------

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

# cloud1
#---------------------------------------------

# queries for "cloud1.lab" forwarded to metadata server

resource "google_dns_managed_zone" "cloud1_to_cloud1" {
  provider    = google-beta
  name        = "${var.cloud1.prefix}to-cloud1"
  dns_name    = "cloud1.lab."
  description = "cloud1.lab local private zone"
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

  managed_zone = google_dns_managed_zone.cloud1_to_cloud1.name
  rrdatas      = [var.cloud1.vm_ip]
}

# queries for "onprem.lab" forwarded to cloud1 DNS proxy

resource "google_dns_managed_zone" "cloud1_to_onprem" {
  provider    = google-beta
  name        = "${var.cloud1.prefix}to-onprem"
  dns_name    = "onprem.lab."
  description = "for onprem.lab, forward to cloud1 DNS proxy"
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

resource "google_dns_managed_zone" "cloud1_to_cloud2" {
  provider    = google-beta
  name        = "${var.cloud1.prefix}to-cloud2"
  dns_name    = "cloud2.lab."
  description = "cloud2.lab. peering zone"
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

resource "google_dns_managed_zone" "cloud1_to_cloud3" {
  provider    = google-beta
  name        = "${var.cloud1.prefix}to-cloud3"
  dns_name    = "cloud3.lab."
  description = "cloud3.lab. peering zone"
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

resource "google_dns_policy" "cloud1_inbound" {
  provider                  = google-beta
  name                      = "${var.cloud1.prefix}inbound"
  enable_inbound_forwarding = true

  networks {
    network_url = local.cloud1.network_self_link
  }
}

# private google access: www.googleapis.com

resource "google_dns_managed_zone" "www_googleapis" {
  provider    = google-beta
  name        = "${var.cloud1.prefix}www-googleapis"
  dns_name    = "www.googleapis.com."
  description = "www.googleapis.com private zone"
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

# private google access: *.googleapis.com

resource "google_dns_managed_zone" "googleapis" {
  provider    = google-beta
  name        = "${var.cloud1.prefix}googleapis"
  dns_name    = "googleapis.com."
  description = "googleapis private zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.cloud1.network_self_link
    }
  }
}

resource "google_dns_record_set" "googleapis_cname" {
  count        = length(var.apis)
  name         = "${element(var.apis, count.index)}.${google_dns_managed_zone.googleapis.dns_name}"
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

# private google access: gcr.io

resource "google_dns_managed_zone" "private_gcr_io" {
  provider    = "google-beta"
  name        = "${var.cloud1.prefix}private-gcr-io"
  dns_name    = "gcr.io."
  description = "gcr.io private zone"
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

resource "google_dns_managed_zone" "cloud2_to_cloud2" {
  provider    = google-beta
  name        = "${var.cloud2.prefix}to-cloud2"
  dns_name    = "cloud2.lab."
  description = "cloud2.lab local private zone"
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

  managed_zone = google_dns_managed_zone.cloud2_to_cloud2.name
  rrdatas      = [var.cloud2.vm_ip]
}

# peering zone to lab.

resource "google_dns_managed_zone" "cloud2_to_lab" {
  provider    = google-beta
  name        = "${var.cloud2.prefix}to-lab"
  dns_name    = "lab."
  description = "for *.lab, use peering zone to cloud1"
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

resource "google_dns_managed_zone" "cloud3_to_cloud3" {
  provider    = google-beta
  name        = "${var.cloud3.prefix}to-cloud3"
  dns_name    = "cloud3.lab."
  description = "cloud3.lab local private zone"
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

  managed_zone = google_dns_managed_zone.cloud3_to_cloud3.name
  rrdatas      = [var.cloud3.vm_ip]
}

# peering zone to lab.

resource "google_dns_managed_zone" "cloud3_to_lab" {
  provider    = google-beta
  name        = "${var.cloud3.prefix}to-lab"
  dns_name    = "lab."
  description = "for *.lab, use peering zone to cloud1"
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
