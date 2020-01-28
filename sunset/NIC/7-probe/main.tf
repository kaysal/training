provider "google" {}
provider "google-beta" {}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "gclb" {
  backend = "local"

  config = {
    path = "../5-gclb/terraform.tfstate"
  }
}

data "terraform_remote_state" "ilb" {
  backend = "local"

  config = {
    path = "../6-ilb/terraform.tfstate"
  }
}

locals {
  probe_init = templatefile("scripts/probe.sh.tpl", {
    GCLB_VIP = data.terraform_remote_state.gclb.outputs.address.spoke1.gclb.address
    ILB_VIP  = data.terraform_remote_state.ilb.outputs.address.spoke2.ilb.address
  })
  hub = {
    subnet_eu   = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet_eu
    subnet_asia = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet_asia
    subnet_us   = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet_us
  }
}

# hub

resource "google_compute_instance" "hub_vm_eu" {
  project                   = var.project_id_spoke1
  name                      = "${var.hub.prefix}vm-eu"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.region_eu}-b"
  metadata_startup_script   = local.probe_init
  allow_stopping_for_update = true
  tags                      = [var.hub.vm_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.subnet_eu.self_link
    network_ip = var.hub.vm_eu_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "hub_vm_asia" {
  project                   = var.project_id_spoke1
  name                      = "${var.hub.prefix}vm-asia"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.region_asia}-b"
  metadata_startup_script   = local.probe_init
  allow_stopping_for_update = true
  tags                      = [var.hub.vm_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.subnet_asia.self_link
    network_ip = var.hub.vm_asia_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "hub_vm_us" {
  project                   = var.project_id_spoke1
  name                      = "${var.hub.prefix}vm-us"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.region_us}-b"
  metadata_startup_script   = local.probe_init
  allow_stopping_for_update = true
  tags                      = [var.hub.vm_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.subnet_us.self_link
    network_ip = var.hub.vm_us_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
