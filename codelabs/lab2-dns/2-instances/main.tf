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

locals {
  instance_init = templatefile("scripts/instance.sh.tpl", {})

  image = {
    debian = "debian-cloud/debian-9"
    ubuntu = "ubuntu-os-cloud/ubuntu-1804-lts"
  }

  onprem = {
    prefix            = "lab2-onprem-"
    region            = "europe-west1"
    vm_ip             = "172.16.1.2"
    dns_proxy_snat_ip = "172.16.1.100"
    dns_proxy_fwd_ip  = "172.16.1.253"
    dns_unbound_ip    = "172.16.1.99"
    subnet_self_link  = data.terraform_remote_state.vpc.outputs.vpc.onprem.subnets.0.self_link
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.onprem.network.self_link
  }

  cloud = {
    prefix                = "lab2-cloud-"
    region                = "europe-west1"
    vm_ip                 = "10.10.1.2"
    dns_proxy_snat_ip     = "10.10.1.100"
    dns_proxy_fwd_ip      = "10.10.1.253"
    dns_policy_inbound_ip = "10.10.1.3"
    subnet_self_link      = data.terraform_remote_state.vpc.outputs.vpc.cloud.subnets.0.self_link
    network_self_link     = data.terraform_remote_state.vpc.outputs.vpc.cloud.network.self_link
  }
}

# onprem
#---------------------------------------------

# vm instance

resource "google_compute_instance" "onprem_vm" {
  name                      = "${local.onprem.prefix}vm"
  machine_type              = "f1-micro"
  zone                      = "${local.onprem.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = local.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet_self_link
    network_ip = local.onprem.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# unbound dns server

locals {
  unbound_init = templatefile("scripts/unbound.sh.tpl", {
    DNS_NAME1            = "vm.onprem.lab"
    DNS_RECORD1          = local.onprem.vm_ip
    DNS_EGRESS_PROXY     = "35.199.192.0/19"
    FORWARD_ZONE1        = "cloud.lab"
    FORWARD_ZONE1_TARGET = local.cloud.dns_proxy_fwd_ip
  })
}

resource "google_compute_instance" "onprem_ns" {
  name                      = "${local.onprem.prefix}ns"
  machine_type              = "n1-standard-1"
  zone                      = "${local.onprem.region}-c"
  metadata_startup_script   = local.unbound_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = local.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet_self_link
    network_ip = local.onprem.dns_unbound_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# proxy for forwarding dns queries to cloud

locals {
  onprem_proxy_init = templatefile("scripts/proxy.sh.tpl", {
    DNAT = "${local.cloud.dns_policy_inbound_ip}"
    SNAT = "${local.onprem.dns_proxy_snat_ip}"
    DEST = "${local.onprem.dns_proxy_fwd_ip}"
  })
}

resource "google_compute_instance" "onprem_dns_proxy" {
  name                      = "${local.onprem.prefix}dns-proxy"
  machine_type              = "f1-micro"
  zone                      = "${local.onprem.region}-d"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.onprem_proxy_init

  boot_disk {
    initialize_params {
      image = local.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet_self_link
    network_ip = local.onprem.dns_proxy_snat_ip
    access_config {}

    alias_ip_range {
      ip_cidr_range = local.onprem.dns_proxy_fwd_ip
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# cloud
#---------------------------------------------

# vm instance

resource "google_compute_instance" "cloud_vm" {
  name                      = "${local.cloud.prefix}vm"
  machine_type              = "f1-micro"
  zone                      = "${local.cloud.region}-d"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = local.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud.subnet_self_link
    network_ip = local.cloud.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# proxy for forwarding dns queries to on-premises

locals {
  cloud_proxy_init = templatefile("scripts/proxy.sh.tpl", {
    DNAT = "${local.onprem.dns_unbound_ip}"
    SNAT = "${local.cloud.dns_proxy_snat_ip}"
    DEST = "${local.cloud.dns_proxy_fwd_ip}"
  })
}

resource "google_compute_instance" "cloud_dns_proxy" {
  name                      = "${local.cloud.prefix}dns-proxy"
  machine_type              = "f1-micro"
  zone                      = "${local.cloud.region}-d"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.cloud_proxy_init

  boot_disk {
    initialize_params {
      image = local.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud.subnet_self_link
    network_ip = local.cloud.dns_proxy_snat_ip
    access_config {}

    alias_ip_range {
      ip_cidr_range = local.cloud.dns_proxy_fwd_ip
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
