provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

data "terraform_remote_state" "network" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

locals {
  default_init = templatefile("scripts/default.sh.tpl", {})
  vpc2         = data.terraform_remote_state.network.outputs.network.vpc2
  subnet = {
    nic_eu  = data.terraform_remote_state.network.outputs.subnetwork.eu.nic
    data_us = data.terraform_remote_state.network.outputs.subnetwork.us.data
  }
}

# data importer us
#-------------------------------------------

# us

resource "google_compute_instance" "data_importer_us" {
  name                      = "data-importer-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.vpc2.us.region}-c"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.subnet.data_us.self_link
    network_ip = var.hub.vpc2.us.ip.data
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "vpc2_eu_vm" {
  name                      = "vpc2-eu-vm"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.vpc2.eu.region}-c"
  allow_stopping_for_update = true
  tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.subnet.nic_eu.self_link
    network_ip = var.hub.vpc2.eu.ip.nic
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
