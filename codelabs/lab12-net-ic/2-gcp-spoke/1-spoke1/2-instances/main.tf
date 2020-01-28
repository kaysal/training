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

locals {
  ext_db_eu_init = templatefile("scripts/data.sh.tpl", {
    TARGET = var.hub.default.us.db_ip
  })
}

resource "google_compute_instance" "ext_db_eu" {
  name                      = "ext-db-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.spoke.custom.eu.region}-c"
  metadata_startup_script   = local.ext_db_eu_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.subnet.custom_eu.self_link
    network_ip = var.spoke.custom.eu.ext_db_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
