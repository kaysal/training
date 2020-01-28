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
  cloud = {
    network     = data.terraform_remote_state.vpc.outputs.networks.cloud.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.cloud.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.cloud.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.cloud.us_subnet
  }
}

# cloud

resource "google_compute_instance" "cloud_eu_vm" {
  project                   = var.project_id_cloud
  name                      = "${var.cloud.prefix}eu-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.cloud.eu.region}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud.eu_subnet.self_link
    network_ip = var.cloud.eu.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "cloud_asia_vm" {
  project                   = var.project_id_cloud
  name                      = "${var.cloud.prefix}asia-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.cloud.asia.region}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud.asia_subnet.self_link
    network_ip = var.cloud.asia.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "cloud_us_vm" {
  project                   = var.project_id_cloud
  name                      = "${var.cloud.prefix}us-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.cloud.us.region}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.cloud.us_subnet.self_link
    network_ip = var.cloud.us.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
