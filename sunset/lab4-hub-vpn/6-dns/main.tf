
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
    network  = data.terraform_remote_state.vpc.outputs.networks.onprem
    subnet_a = data.terraform_remote_state.vpc.outputs.cidrs.onprem_a
    subnet_b = data.terraform_remote_state.vpc.outputs.cidrs.onprem_b
  }
  hub = {
    network  = data.terraform_remote_state.vpc.outputs.networks.hub
    subnet_a = data.terraform_remote_state.vpc.outputs.cidrs.hub_a
    subnet_b = data.terraform_remote_state.vpc.outputs.cidrs.hub_b
  }
  spoke1 = {
    network  = data.terraform_remote_state.vpc.outputs.networks.spoke1
    subnet_a = data.terraform_remote_state.vpc.outputs.cidrs.spoke1_a
    subnet_b = data.terraform_remote_state.vpc.outputs.cidrs.spoke1_b
  }
  spoke2 = {
    network  = data.terraform_remote_state.vpc.outputs.networks.spoke2
    subnet_a = data.terraform_remote_state.vpc.outputs.cidrs.spoke2_a
    subnet_b = data.terraform_remote_state.vpc.outputs.cidrs.spoke2_b
  }
}

# onprem
#---------------------------------------------

# queries for "onprem.lab." forwarded to unbound server

resource "google_dns_managed_zone" "onprem_to_onprem" {
  provider    = google-beta
  name        = "${var.onprem.prefix}to-onprem"
  dns_name    = "onprem.lab."
  description = "for *.onprem.lab, forward to onprem unbound server"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.onprem.network.self_link
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
      network_url = local.onprem.network.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = var.onprem.dns_proxy_ip
    }
  }
}

# queries for "." forwarded to onprem unbound server

resource "google_dns_managed_zone" "onprem_to_all" {
  provider    = google-beta
  name        = "${var.onprem.prefix}to-all"
  dns_name    = "."
  description = "for all (.), forward to onprem unbound server"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.onprem.network.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = var.onprem.dns_unbound_ip
    }
  }
}

# hub
#---------------------------------------------

# queries for "onprem.lab" forwarded to hub DNS proxy

resource "google_dns_managed_zone" "hub_to_onprem" {
  provider    = google-beta
  name        = "${var.hub.prefix}to-onprem"
  dns_name    = "onprem.lab."
  description = "for onprem.lab, forward to hub DNS proxy"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.hub.network.self_link
    }
  }

  forwarding_config {
    target_name_servers {
      ipv4_address = var.hub.dns_proxy_ip
    }
  }
}

# peering zone to spoke1.lab.

resource "google_dns_managed_zone" "hub_to_spoke1" {
  provider    = google-beta
  name        = "${var.hub.prefix}to-spoke1"
  dns_name    = "spoke1.lab."
  description = "spoke1.lab. peering zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.hub.network.self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.spoke1.network.self_link
    }
  }
}

# peering zone to spoke2.lab.

resource "google_dns_managed_zone" "hub_to_spoke2" {
  provider    = google-beta
  name        = "${var.hub.prefix}to-spoke2"
  dns_name    = "spoke2.lab."
  description = "spoke2.lab. peering zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.hub.network.self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.spoke2.network.self_link
    }
  }
}

# inbound dns policy

resource "google_dns_policy" "hub_inbound" {
  provider                  = google-beta
  name                      = "${var.hub.prefix}inbound"
  enable_inbound_forwarding = true

  networks {
    network_url = local.hub.network.self_link
  }
}

# spoke1
#---------------------------------------------

# private zone for spoke1 VPC

resource "google_dns_managed_zone" "spoke1_to_spoke1" {
  provider    = google-beta
  name        = "${var.spoke1.prefix}to-spoke1"
  dns_name    = "spoke1.lab."
  description = "spoke1.lab local private zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.spoke1.network.self_link
    }
  }
}

# A Records

resource "google_dns_record_set" "spoke1_vm_a_record" {
  name = "vma.spoke1.lab."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.spoke1_to_spoke1.name
  rrdatas      = [var.spoke1.vm_a_ip]
}

resource "google_dns_record_set" "spoke1_vm_b_record" {
  name = "vmb.spoke1.lab."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.spoke1_to_spoke1.name
  rrdatas      = [var.spoke1.vm_b_ip]
}

# peering zone = lab.

resource "google_dns_managed_zone" "spoke1_to_lab" {
  provider    = google-beta
  name        = "${var.spoke1.prefix}to-lab"
  dns_name    = "lab."
  description = "for *.lab, use peering zone to hub"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.spoke1.network.self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.hub.network.self_link
    }
  }
}


# zone = googleapis.com.

resource "google_dns_managed_zone" "spoke1_googleapis" {
  provider    = google-beta
  name        = "${var.spoke1.prefix}googleapis"
  dns_name    = "googleapis.com."
  description = "googleapis private zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.spoke1.network.self_link
    }
  }
}

# zone = gcr.io

resource "google_dns_managed_zone" "spoke1_private_gcr_io" {
  provider    = "google-beta"
  name        = "${var.spoke1.prefix}private-gcr-io"
  dns_name    = "gcr.io."
  description = "gcr.io private zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.spoke1.network.self_link
    }
  }
}

# restricted.googleapis.com is used for APIs for VPC SC

resource "google_dns_record_set" "spoke1_restricted_googleapis_cname" {
  count        = length(var.restricted_apis)
  name         = "${element(var.restricted_apis, count.index)}.${google_dns_managed_zone.spoke1_googleapis.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.spoke1_googleapis.name
  rrdatas      = ["restricted.${google_dns_managed_zone.spoke1_googleapis.dns_name}"]
}

resource "google_dns_record_set" "spoke1_restricted_googleapis" {
  name = "restricted.${google_dns_managed_zone.spoke1_googleapis.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.spoke1_googleapis.name

  rrdatas = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]
}

# restricted.googleapis.com is used for gcr.io

resource "google_dns_record_set" "spoke1_gcr_io_cname" {
  name = "*.gcr.io."
  type = "CNAME"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.spoke1_private_gcr_io.name}"
  rrdatas      = ["gcr.io."]
}

resource "google_dns_record_set" "spoke1_restricted_gcr_io" {
  name = "gcr.io."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.spoke1_private_gcr_io.name

  rrdatas = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]
}

# private.googleapis.com is used for all other googleapis

resource "google_dns_record_set" "spoke1_private_googleapis_cname" {
  name         = "*.${google_dns_managed_zone.spoke1_googleapis.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.spoke1_googleapis.name
  rrdatas      = ["private.${google_dns_managed_zone.spoke1_googleapis.dns_name}"]
}

resource "google_dns_record_set" "spoke1_private_googleapis" {
  name = "private.${google_dns_managed_zone.spoke1_googleapis.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.spoke1_googleapis.name

  rrdatas = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11",
  ]
}

# spoke2
#---------------------------------------------

# private zone for spoke2 VPC

resource "google_dns_managed_zone" "spoke2_to_spoke2" {
  provider    = google-beta
  name        = "${var.spoke2.prefix}to-spoke2"
  dns_name    = "spoke2.lab."
  description = "spoke2.lab local private zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.spoke2.network.self_link
    }
  }
}

# A Records

resource "google_dns_record_set" "spoke2_vm_a_record" {
  name = "vma.spoke2.lab."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.spoke2_to_spoke2.name
  rrdatas      = [var.spoke2.vm_a_ip]
}

resource "google_dns_record_set" "spoke2_vm_b_record" {
  name = "vmb.spoke2.lab."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.spoke2_to_spoke2.name
  rrdatas      = [var.spoke2.vm_b_ip]
}

# peering zone to lab.

resource "google_dns_managed_zone" "spoke2_to_lab" {
  provider    = google-beta
  name        = "${var.spoke2.prefix}to-lab"
  dns_name    = "lab."
  description = "for *.lab, use peering zone to hub"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.spoke2.network.self_link
    }
  }

  peering_config {
    target_network {
      network_url = local.hub.network.self_link
    }
  }
}

# zone = googleapis.com.

resource "google_dns_managed_zone" "spoke2_googleapis" {
  provider    = google-beta
  name        = "${var.spoke2.prefix}googleapis"
  dns_name    = "googleapis.com."
  description = "googleapis private zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.spoke2.network.self_link
    }
  }
}

# zone = gcr.io

resource "google_dns_managed_zone" "spoke2_private_gcr_io" {
  provider    = "google-beta"
  name        = "${var.spoke2.prefix}private-gcr-io"
  dns_name    = "gcr.io."
  description = "gcr.io private zone"
  visibility  = "private"

  private_visibility_config {
    networks {
      network_url = local.spoke2.network.self_link
    }
  }
}

# restricted.googleapis.com is used for APIs for VPC SC

resource "google_dns_record_set" "spoke2_restricted_googleapis_cname" {
  count        = length(var.restricted_apis)
  name         = "${element(var.restricted_apis, count.index)}.${google_dns_managed_zone.spoke2_googleapis.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.spoke2_googleapis.name
  rrdatas      = ["restricted.${google_dns_managed_zone.spoke2_googleapis.dns_name}"]
}

resource "google_dns_record_set" "spoke2_restricted_googleapis" {
  name = "restricted.${google_dns_managed_zone.spoke2_googleapis.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.spoke2_googleapis.name

  rrdatas = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]
}

# restricted.googleapis.com is used for gcr.io

resource "google_dns_record_set" "spoke2_gcr_io_cname" {
  name = "*.gcr.io."
  type = "CNAME"
  ttl  = 300

  managed_zone = "${google_dns_managed_zone.spoke2_private_gcr_io.name}"
  rrdatas      = ["gcr.io."]
}

resource "google_dns_record_set" "spoke2_restricted_gcr_io" {
  name = "gcr.io."
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.spoke2_private_gcr_io.name

  rrdatas = [
    "199.36.153.4",
    "199.36.153.5",
    "199.36.153.6",
    "199.36.153.7",
  ]
}

# private.googleapis.com is used for all other googleapis

resource "google_dns_record_set" "spoke2_private_googleapis_cname" {
  name         = "*.${google_dns_managed_zone.spoke2_googleapis.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.spoke2_googleapis.name
  rrdatas      = ["private.${google_dns_managed_zone.spoke2_googleapis.dns_name}"]
}

resource "google_dns_record_set" "spoke2_private_googleapis" {
  name = "private.${google_dns_managed_zone.spoke2_googleapis.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.spoke2_googleapis.name

  rrdatas = [
    "199.36.153.8",
    "199.36.153.9",
    "199.36.153.10",
    "199.36.153.11",
  ]
}
