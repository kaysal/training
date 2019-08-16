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
  cloud = {
    subnet  = data.terraform_remote_state.vpc.outputs.subnets.cloud.self_link
    network = data.terraform_remote_state.vpc.outputs.networks.cloud.self_link
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
    subnetwork = local.cloud.subnet
    network_ip = var.cloud.vm_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
