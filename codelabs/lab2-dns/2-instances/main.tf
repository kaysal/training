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
    subnet  = data.terraform_remote_state.vpc.outputs.subnets.onprem.self_link
    network = data.terraform_remote_state.vpc.outputs.networks.onprem.self_link
  }
  cloud1 = {
    subnet  = data.terraform_remote_state.vpc.outputs.subnets.cloud1.self_link
    network = data.terraform_remote_state.vpc.outputs.networks.cloud1.self_link
  }
  cloud2 = {
    subnet  = data.terraform_remote_state.vpc.outputs.subnets.cloud2.self_link
    network = data.terraform_remote_state.vpc.outputs.networks.cloud2.self_link
  }
  cloud3 = {
    subnet  = data.terraform_remote_state.vpc.outputs.subnets.cloud3.self_link
    network = data.terraform_remote_state.vpc.outputs.networks.cloud3.self_link
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
    subnetwork = local.onprem.subnet
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
    FORWARD_ZONE1        = "cloud1.lab"
    FORWARD_ZONE1_TARGET = var.cloud1.dns_inbound_ip
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
    subnetwork = local.onprem.subnet
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
    REMOTE_DNS_IP = "${var.cloud1.dns_inbound_ip}"
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
    subnetwork = local.onprem.subnet
    network_ip = var.onprem.dns_proxy_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# cloud1
#---------------------------------------------

# vm instance

resource "google_compute_instance" "cloud1_vm" {
  name                      = "${var.cloud1.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.cloud1.region}-d"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud1.subnet
    network_ip = var.cloud1.vm_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# proxy for forwarding dns queries to on-premises

locals {
  cloud1_proxy_init = templatefile("scripts/proxy.sh.tpl", {
    DNS_PROXY_IP  = "${var.cloud1.dns_proxy_ip}"
    REMOTE_DNS_IP = "${var.onprem.dns_unbound_ip}"
  })
}

resource "google_compute_instance" "cloud1_dns_proxy" {
  name                      = "${var.cloud1.prefix}proxy"
  machine_type              = var.global.machine_type
  zone                      = "${var.cloud1.region}-d"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.cloud1_proxy_init

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud1.subnet
    network_ip = var.cloud1.dns_proxy_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# cloud2
#---------------------------------------------

# vm instance

resource "google_compute_instance" "cloud2_vm" {
  name                      = "${var.cloud2.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.cloud2.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud2.subnet
    network_ip = var.cloud2.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# cloud3
#---------------------------------------------

# vm instance

resource "google_compute_instance" "cloud3_vm" {
  name                      = "${var.cloud3.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.cloud3.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud3.subnet
    network_ip = var.cloud3.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
