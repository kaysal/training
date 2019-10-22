provider "google" {}
provider "google-beta" {}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

locals {
  web_init = templatefile("scripts/web.sh.tpl", {})
  vpc1 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.vpc1.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.vpc1.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.vpc1.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.vpc1.us_subnet
  }
}

# vpc1

resource "google_compute_instance" "vpc1_eu_vm" {
  project                   = var.project_id_vpc1
  name                      = "${var.vpc1.prefix}eu-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.vpc1.eu.region}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.vpc1.hc_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.vpc1.eu_subnet.self_link
    network_ip = var.vpc1.eu.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "vpc1_asia_vm" {
  project                   = var.project_id_vpc1
  name                      = "${var.vpc1.prefix}asia-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.vpc1.asia.region}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.vpc1.hc_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.vpc1.asia_subnet.self_link
    network_ip = var.vpc1.asia.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "vpc1_us_vm" {
  project                   = var.project_id_vpc1
  name                      = "${var.vpc1.prefix}us-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.vpc1.us.region}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.vpc1.hc_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.vpc1.us_subnet.self_link
    network_ip = var.vpc1.us.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
