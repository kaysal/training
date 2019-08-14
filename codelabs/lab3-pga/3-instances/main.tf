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

  onprem = {
    subnet_self_link  = data.terraform_remote_state.vpc.outputs.vpc.onprem.subnets.0.self_link
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.onprem.network.self_link
  }

  cloud = {
    subnet_self_link  = data.terraform_remote_state.vpc.outputs.vpc.cloud.subnets.0.self_link
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.cloud.network.self_link
  }
}

# onprem
#---------------------------------------------

# vm instance

resource "google_compute_instance" "onprem_vm" {
  name                      = "${var.onprem.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet_self_link
    network_ip = var.onprem.vm_ip
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
    DNS_RECORD1          = var.onprem.vm_ip
    DNS_EGRESS_PROXY     = "35.199.192.0/19"
    FORWARD_ZONE1        = "cloud.lab"
    FORWARD_ZONE1_TARGET = var.cloud.dns_inbound_ip
  })
}

resource "google_compute_instance" "onprem_ns" {
  name                      = "${var.onprem.prefix}ns"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region}-c"
  metadata_startup_script   = local.unbound_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet_self_link
    network_ip = var.onprem.dns_unbound_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# proxy for forwarding dns queries to cloud

locals {
  onprem_proxy_init = templatefile("scripts/proxy.sh.tpl", {
    DNS_PROXY_IP  = "${var.onprem.dns_proxy_ip}"
    REMOTE_DNS_IP = "${var.cloud.dns_inbound_ip}"
  })
}

resource "google_compute_instance" "onprem_dns_proxy" {
  name                      = "${var.onprem.prefix}proxy"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region}-d"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.onprem_proxy_init

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet_self_link
    network_ip = var.onprem.dns_proxy_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# cloud
#---------------------------------------------

# vm instance

resource "google_compute_instance" "cloud_vm" {
  name                      = "${var.cloud.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.cloud.region}-d"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud.subnet_self_link
    network_ip = var.cloud.vm_ip
    #access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# proxy for forwarding dns queries to on-premises

locals {
  cloud_proxy_init = templatefile("scripts/proxy.sh.tpl", {
    DNS_PROXY_IP  = "${var.cloud.dns_proxy_ip}"
    REMOTE_DNS_IP = "${var.onprem.dns_unbound_ip}"
  })
}

resource "google_compute_instance" "cloud_dns_proxy" {
  name                      = "${var.cloud.prefix}proxy"
  machine_type              = var.global.machine_type
  zone                      = "${var.cloud.region}-d"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.cloud_proxy_init

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud.subnet_self_link
    network_ip = var.cloud.dns_proxy_ip
    #access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
