provider "google" {}

provider "google-beta" {}

provider "random" {}

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
    path = "../8-gclb/terraform.tfstate"
  }
}

data "terraform_remote_state" "ilb" {
  backend = "local"

  config = {
    path = "../9-ilb/terraform.tfstate"
  }
}

locals {
  onprem = {
    network = data.terraform_remote_state.vpc.outputs.networks.onprem.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet2
    subnet3 = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet3
  }
  spoke1 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke1.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet2
    gclb    = data.terraform_remote_state.gclb.outputs.addresses.spoke1.gclb
  }
  spoke2 = {
    network = data.terraform_remote_state.vpc.outputs.networks.spoke2.network
    subnet1 = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet2
    ilb     = data.terraform_remote_state.ilb.outputs.addresses.spoke2.ilb
  }
}

# prober
#---------------------------------------------

locals {
  prober_init = templatefile("scripts/prober.sh.tpl", {
    VIP_GCLB = local.spoke1.gclb.address
  })
}

resource "google_compute_instance" "prober" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}prober"
  machine_type              = "n1-standard-1"
  zone                      = "${var.onprem.region}-c"
  metadata_startup_script   = local.prober_init
  allow_stopping_for_update = true
  tags                      = ["${var.onprem.prefix}prober"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet1.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
