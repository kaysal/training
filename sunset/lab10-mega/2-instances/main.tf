provider "google" {}

provider "google-beta" {}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "../0-iam/terraform.tfstate"
  }
}

locals {
  instance_init = templatefile("scripts/instance.sh.tpl", {})
  onprem = {
    eu_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.onprem.eu_cidr
    asia_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.onprem.asia_cidr
    us_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.onprem.us_cidr
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.onprem
  }
  hub = {
    vpc_eu1     = data.terraform_remote_state.vpc.outputs.networks.hub.eu1
    vpc_eu2     = data.terraform_remote_state.vpc.outputs.networks.hub.eu2
    vpc_eux     = data.terraform_remote_state.vpc.outputs.networks.hub.eux
    vpc_asia1   = data.terraform_remote_state.vpc.outputs.networks.hub.asia1
    vpc_asia2   = data.terraform_remote_state.vpc.outputs.networks.hub.asia2
    vpc_asiax   = data.terraform_remote_state.vpc.outputs.networks.hub.asiax
    vpc_us1     = data.terraform_remote_state.vpc.outputs.networks.hub.us1
    vpc_us2     = data.terraform_remote_state.vpc.outputs.networks.hub.us2
    vpc_usx     = data.terraform_remote_state.vpc.outputs.networks.hub.usx
    eu1_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu1_cidr
    eu2_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu2_cidr
    eu1_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu1_cidrx
    eu2_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu2_cidrx
    asia1_cidr  = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia1_cidr
    asia2_cidr  = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia2_cidr
    asia1_cidrx = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia1_cidrx
    asia2_cidrx = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia2_cidrx
    us1_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.us1_cidr
    us2_cidr    = data.terraform_remote_state.vpc.outputs.cidrs.hub.us2_cidr
    us1_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.us1_cidrx
    us2_cidrx   = data.terraform_remote_state.vpc.outputs.cidrs.hub.us2_cidrx
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.hub
  }
  svc = {
    eu_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.svc.eu_cidr
    asia_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.svc.asia_cidr
    us_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.svc.us_cidr
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.svc
  }
}

# onprem
#===============================================

# eu vm

resource "google_compute_instance" "onprem_vm_eu" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}vm-eu"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.eu.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.eu_cidr.self_link
    network_ip = var.onprem.eu.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# eu unbound dns server

locals {
  unbound_init = templatefile("scripts/unbound.sh.tpl", {
    NAME_LAB_ONPREM_PROXY_IP   = "proxy.eu.onprem.lab"
    RECORD_LAB_ONPREM_PROXY_IP = var.onprem.eu.proxy_ip
    NAME_LAB_ONPREM_VM_ASIA    = "vm.asia.onprem.lab"
    RECORD_LAB_ONPREM_VM_ASIA  = var.onprem.asia.vm_ip
    NAME_LAB_ONPREM_VM_US      = "vm.us.onprem.lab"
    RECORD_LAB_ONPREM_VM_US    = var.onprem.us.vm_ip
    EGRESS_PROXY               = "35.199.192.0/19"
  })
}

resource "google_compute_instance" "onprem_unbound" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}unbound"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.eu.region}-b"
  metadata_startup_script   = local.unbound_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.eu_cidr.self_link
    network_ip = var.onprem.eu.unbound_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# proxy for forwarding dns queries to hub

locals {
  onprem_proxy_init = templatefile("scripts/proxy-onprem.sh.tpl", {
    ONPREM_EU1_PROXY    = "${var.onprem.eu.proxy_eu1_ip}"
    HUB_EU1_DNS_INBOUND = "${var.hub.eu1.dns_inbound_ip}"
  })
}

resource "google_compute_instance" "onprem_dns_proxy" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}proxy"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.eu.region}-c"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.onprem_proxy_init

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.eu_cidr.self_link
    network_ip = var.onprem.eu.proxy_ip
    access_config {}

    alias_ip_range {
      subnetwork_range_name = "dns-range"
      ip_cidr_range         = var.onprem.eu.proxy_eu1_ip
    }
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# asia vm

resource "google_compute_instance" "onprem_vm_asia" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}vm-asia"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.asia.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.asia_cidr.self_link
    network_ip = var.onprem.asia.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# us vm

resource "google_compute_instance" "onprem_vm_us" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}vm-us"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.us.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.us_cidr.self_link
    network_ip = var.onprem.us.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# hub
#===============================================

# eu1

## proxy instance

locals {
  hub_eu1_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    ONPREM_UNBOUND_IP        = var.onprem.eu.unbound_ip
    HUB_PROXY_IP             = var.hub.eu1.proxy_ip
    HUB_PROXY_IPX            = var.hub.eu1.proxy_ipx
    HUB_PROXY_IPX_DEFAULT_GW = var.hub.eu1.cidrx_default_gw
    SVC_EU_SUBNET            = var.svc.eu.cidr
    SVC_ASIA_SUBNET          = var.svc.asia.cidr
    SVC_US_SUBNET            = var.svc.us.cidr
  })
}

resource "google_compute_instance" "hub_proxy_eu1" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-eu1"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.eu1.region}-b"
  metadata_startup_script   = local.hub_eu1_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.eu1_cidr.self_link
    network_ip = var.hub.eu1.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.eu1_cidrx.self_link
    network_ip = var.hub.eu1.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# eu2

## proxy instance

locals {
  hub_eu2_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    ONPREM_UNBOUND_IP        = var.onprem.eu.unbound_ip
    HUB_PROXY_IP             = var.hub.eu2.proxy_ip
    HUB_PROXY_IPX            = var.hub.eu2.proxy_ipx
    HUB_PROXY_IPX_DEFAULT_GW = var.hub.eu2.cidrx_default_gw
    SVC_EU_SUBNET            = var.svc.eu.cidr
    SVC_ASIA_SUBNET          = var.svc.asia.cidr
    SVC_US_SUBNET            = var.svc.us.cidr
  })
}

resource "google_compute_instance" "hub_proxy_eu2" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-eu2"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.eu2.region}-b"
  metadata_startup_script   = local.hub_eu2_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.eu2_cidr.self_link
    network_ip = var.hub.eu2.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.eu2_cidrx.self_link
    network_ip = var.hub.eu2.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# proxy asia1

locals {
  hub_asia1_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    ONPREM_UNBOUND_IP        = var.onprem.eu.unbound_ip
    HUB_PROXY_IP             = var.hub.asia1.proxy_ip
    HUB_PROXY_IPX            = var.hub.asia1.proxy_ipx
    HUB_PROXY_IPX_DEFAULT_GW = var.hub.asia1.cidrx_default_gw
    SVC_EU_SUBNET            = var.svc.eu.cidr
    SVC_ASIA_SUBNET          = var.svc.asia.cidr
    SVC_US_SUBNET            = var.svc.us.cidr
  })
}

resource "google_compute_instance" "hub_proxy_asia1" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-asia1"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.asia1.region}-b"
  metadata_startup_script   = local.hub_asia1_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.asia1_cidr.self_link
    network_ip = var.hub.asia1.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.asia1_cidrx.self_link
    network_ip = var.hub.asia1.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# proxy asia2

locals {
  hub_asia2_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    ONPREM_UNBOUND_IP        = var.onprem.eu.unbound_ip
    HUB_PROXY_IP             = var.hub.asia2.proxy_ip
    HUB_PROXY_IPX            = var.hub.asia2.proxy_ipx
    HUB_PROXY_IPX_DEFAULT_GW = var.hub.asia2.cidrx_default_gw
    SVC_EU_SUBNET            = var.svc.eu.cidr
    SVC_ASIA_SUBNET          = var.svc.asia.cidr
    SVC_US_SUBNET            = var.svc.us.cidr
  })
}

resource "google_compute_instance" "hub_proxy_asia2" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-asia2"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.asia2.region}-b"
  metadata_startup_script   = local.hub_asia2_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.asia2_cidr.self_link
    network_ip = var.hub.asia2.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.asia2_cidrx.self_link
    network_ip = var.hub.asia2.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# proxy us1

locals {
  hub_us1_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    ONPREM_UNBOUND_IP        = var.onprem.eu.unbound_ip
    HUB_PROXY_IP             = var.hub.us1.proxy_ip
    HUB_PROXY_IPX            = var.hub.us1.proxy_ipx
    HUB_PROXY_IPX_DEFAULT_GW = var.hub.us1.cidrx_default_gw
    SVC_EU_SUBNET            = var.svc.eu.cidr
    SVC_ASIA_SUBNET          = var.svc.asia.cidr
    SVC_US_SUBNET            = var.svc.us.cidr
  })
}

resource "google_compute_instance" "hub_proxy_us1" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-us1"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.us1.region}-b"
  metadata_startup_script   = local.hub_us1_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.us1_cidr.self_link
    network_ip = var.hub.us1.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.us1_cidrx.self_link
    network_ip = var.hub.us1.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# proxy us2

locals {
  hub_us2_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    ONPREM_UNBOUND_IP        = var.onprem.eu.unbound_ip
    HUB_PROXY_IP             = var.hub.us2.proxy_ip
    HUB_PROXY_IPX            = var.hub.us2.proxy_ipx
    HUB_PROXY_IPX_DEFAULT_GW = var.hub.us2.cidrx_default_gw
    SVC_EU_SUBNET            = var.svc.eu.cidr
    SVC_ASIA_SUBNET          = var.svc.asia.cidr
    SVC_US_SUBNET            = var.svc.us.cidr
  })
}

resource "google_compute_instance" "hub_proxy_us2" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-us2"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.us2.region}-b"
  metadata_startup_script   = local.hub_us2_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.us2_cidr.self_link
    network_ip = var.hub.us2.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.us2_cidrx.self_link
    network_ip = var.hub.us2.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# svc
#===============================================

# vm_eu

resource "google_compute_instance" "svc_vm_eu" {
  project                   = var.project_id_svc
  name                      = "${var.svc.prefix}vm-eu"
  machine_type              = var.global.machine_type
  zone                      = "${var.svc.eu.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.eu_cidr.self_link
    network_ip = var.svc.eu.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}

# vm_asia

resource "google_compute_instance" "svc_vm_asia" {
  project                   = var.project_id_svc
  name                      = "${var.svc.prefix}vm-asia"
  machine_type              = var.global.machine_type
  zone                      = "${var.svc.asia.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.asia_cidr.self_link
    network_ip = var.svc.asia.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}

# vm_us

resource "google_compute_instance" "svc_vm_us" {
  project                   = var.project_id_svc
  name                      = "${var.svc.prefix}vm-us"
  machine_type              = var.global.machine_type
  zone                      = "${var.svc.us.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.us_cidr.self_link
    network_ip = var.svc.us.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}

# routes
#===============================================

# svc routes
#------------------------------------

# route to svc --> eu1 proxy

resource "google_compute_route" "eu_svc_via_eu1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu-svc-via-eu1-proxy"
  dest_range             = "10.1.0.0/24"
  network                = local.hub.vpc_eu1.self_link
  next_hop_instance_zone = "${var.hub.eu1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu1.name
  priority               = 100
}

resource "google_compute_route" "asia_svc_via_eu1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia-svc-via-eu1-proxy"
  dest_range             = "10.2.0.0/24"
  network                = local.hub.vpc_eu1.self_link
  next_hop_instance_zone = "${var.hub.eu1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu1.name
  priority               = 100
}

resource "google_compute_route" "us_svc_via_eu1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us-svc-via-eu1-proxy"
  dest_range             = "10.3.0.0/24"
  network                = local.hub.vpc_eu1.self_link
  next_hop_instance_zone = "${var.hub.eu1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu1.name
  priority               = 100
}

# route to svc --> eu2 proxy

resource "google_compute_route" "eu_svc_via_eu2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu-svc-via-eu2-proxy"
  dest_range             = "10.1.0.0/24"
  network                = local.hub.vpc_eu2.self_link
  next_hop_instance_zone = "${var.hub.eu2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu2.name
  priority               = 100
}

resource "google_compute_route" "asia_svc_via_eu2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia-svc-via-eu2-proxy"
  dest_range             = "10.2.0.0/24"
  network                = local.hub.vpc_eu2.self_link
  next_hop_instance_zone = "${var.hub.eu2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu2.name
  priority               = 100
}

resource "google_compute_route" "us_svc_via_eu2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us-svc-via-eu2-proxy"
  dest_range             = "10.3.0.0/24"
  network                = local.hub.vpc_eu2.self_link
  next_hop_instance_zone = "${var.hub.eu2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu2.name
  priority               = 100
}

# route to svc --> asia1 proxy

resource "google_compute_route" "eu_svc_via_asia1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu-svc-via-asia1-proxy"
  dest_range             = "10.1.0.0/24"
  network                = local.hub.vpc_asia1.self_link
  next_hop_instance_zone = "${var.hub.asia1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia1.name
  priority               = 100
}

resource "google_compute_route" "asia_svc_via_asia1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia-svc-via-asia1-proxy"
  dest_range             = "10.2.0.0/24"
  network                = local.hub.vpc_asia1.self_link
  next_hop_instance_zone = "${var.hub.asia1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia1.name
  priority               = 100
}

resource "google_compute_route" "us_svc_via_asia1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us-svc-via-asia1-proxy"
  dest_range             = "10.3.0.0/24"
  network                = local.hub.vpc_asia1.self_link
  next_hop_instance_zone = "${var.hub.asia1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia1.name
  priority               = 100
}

# route to svc --> asia2 proxy

resource "google_compute_route" "eu_svc_via_asia2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu-svc-via-asia2-proxy"
  dest_range             = "10.1.0.0/24"
  network                = local.hub.vpc_asia2.self_link
  next_hop_instance_zone = "${var.hub.asia2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia2.name
  priority               = 100
}

resource "google_compute_route" "asia_svc_via_asia2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia-svc-via-asia2-proxy"
  dest_range             = "10.2.0.0/24"
  network                = local.hub.vpc_asia2.self_link
  next_hop_instance_zone = "${var.hub.asia2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia2.name
  priority               = 100
}

resource "google_compute_route" "us_svc_via_asia2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us-svc-via-asia2-proxy"
  dest_range             = "10.3.0.0/24"
  network                = local.hub.vpc_asia2.self_link
  next_hop_instance_zone = "${var.hub.asia2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia2.name
  priority               = 100
}

# route to svc --> us1 proxy

resource "google_compute_route" "eu_svc_via_us1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu-svc-via-us1-proxy"
  dest_range             = "10.1.0.0/24"
  network                = local.hub.vpc_us1.self_link
  next_hop_instance_zone = "${var.hub.us1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us1.name
  priority               = 100
}

resource "google_compute_route" "asia_svc_via_us1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia-svc-via-us1-proxy"
  dest_range             = "10.2.0.0/24"
  network                = local.hub.vpc_us1.self_link
  next_hop_instance_zone = "${var.hub.us1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us1.name
  priority               = 100
}

resource "google_compute_route" "us_svc_via_us1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us-svc-via-us1-proxy"
  dest_range             = "10.3.0.0/24"
  network                = local.hub.vpc_us1.self_link
  next_hop_instance_zone = "${var.hub.us1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us1.name
  priority               = 100
}

# route to svc --> us2 proxy

resource "google_compute_route" "eu_svc_via_us2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu-svc-via-us2-proxy"
  dest_range             = "10.1.0.0/24"
  network                = local.hub.vpc_us2.self_link
  next_hop_instance_zone = "${var.hub.us2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us2.name
  priority               = 100
}

resource "google_compute_route" "asia_svc_via_us2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia-svc-via-us2-proxy"
  dest_range             = "10.2.0.0/24"
  network                = local.hub.vpc_us2.self_link
  next_hop_instance_zone = "${var.hub.us2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us2.name
  priority               = 100
}

resource "google_compute_route" "us_svc_via_us2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us-svc-via-us2-proxy"
  dest_range             = "10.3.0.0/24"
  network                = local.hub.vpc_us2.self_link
  next_hop_instance_zone = "${var.hub.us2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us2.name
  priority               = 100
}

# onprem routes
#------------------------------------

# route to onprem eu --> eu1 and eu proxies

resource "google_compute_route" "onprem_eu_via_eu1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}onprem-eu-via-eu1-proxy"
  dest_range             = "172.16.1.0/24"
  network                = local.hub.vpc_eux.self_link
  next_hop_instance_zone = "${var.hub.eu2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu1.name
  priority               = 100
}

resource "google_compute_route" "onprem_eu_via_eu2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}onprem-eu-via-eu2-proxy"
  dest_range             = "172.16.1.0/24"
  network                = local.hub.vpc_eux.self_link
  next_hop_instance_zone = "${var.hub.eu2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu2.name
  priority               = 100
}

# route to onprem asia --> asia1 and asia1 proxy

resource "google_compute_route" "onprem_asia_via_asia1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}onprem-asia-via-asia1-proxy"
  dest_range             = "172.16.2.0/24"
  network                = local.hub.vpc_asiax.self_link
  next_hop_instance_zone = "${var.hub.asia2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia1.name
  priority               = 100
}

resource "google_compute_route" "onprem_asia_via_asia2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}onprem-asia-via-asia2-proxy"
  dest_range             = "172.16.2.0/24"
  network                = local.hub.vpc_asiax.self_link
  next_hop_instance_zone = "${var.hub.asia2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia2.name
  priority               = 100
}

# route to onprem us --> us1 and us2 proxies

resource "google_compute_route" "onprem_us_via_us1_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}onprem-us-via-us1-proxy"
  dest_range             = "172.16.3.0/24"
  network                = local.hub.vpc_usx.self_link
  next_hop_instance_zone = "${var.hub.us2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us1.name
  priority               = 100
}

resource "google_compute_route" "onprem_us_via_us2_proxy" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}onprem-us-via-us2-proxy"
  dest_range             = "172.16.3.0/24"
  network                = local.hub.vpc_usx.self_link
  next_hop_instance_zone = "${var.hub.us2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us2.name
  priority               = 100
}
