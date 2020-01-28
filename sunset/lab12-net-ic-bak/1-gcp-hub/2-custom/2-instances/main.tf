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
  custom       = data.terraform_remote_state.network.outputs.network.custom
  subnet = {
    custom_eu = data.terraform_remote_state.network.outputs.network.subnet.custom_eu
    custom_us = data.terraform_remote_state.network.outputs.network.subnet.custom_us
  }
}

# data importer us
#-------------------------------------------

# us

resource "google_compute_instance" "data_importer_us" {
  name                      = "data-importer-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.custom.us.region}-c"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.subnet.custom_us.self_link
    network_ip = var.hub.custom.us.data_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "vpc2_eu_vm" {
  name                      = "vpc2-eu-vm"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.custom.eu.region}-c"
  allow_stopping_for_update = true
  tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.subnet.custom_eu.self_link
    network_ip = var.hub.custom.eu.test_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
