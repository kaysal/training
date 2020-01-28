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

locals {
  vpc2 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.vpc2.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.vpc2.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.vpc2.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.vpc2.us_subnet
  }
}

# vpc2

locals {
  eu_probe_init = templatefile("scripts/probe.sh.tpl", {
    TARGET1 = data.terraform_remote_state.gclb.outputs.address.vpc1.gclb.address
    TARGET2 = var.vpc2.us.vm_ip
  })
  asia_probe_init = templatefile("scripts/probe.sh.tpl", {
    TARGET1 = data.terraform_remote_state.gclb.outputs.address.vpc1.gclb.address
    TARGET2 = var.vpc2.us.vm_ip
  })
  us_probe_init = templatefile("scripts/probe.sh.tpl", {
    TARGET1 = data.terraform_remote_state.gclb.outputs.address.vpc1.gclb.address
    TARGET2 = "google.com"
  })
}

resource "google_compute_instance" "vpc2_eu_vm" {
  project                   = var.project_id_vpc1
  name                      = "${var.vpc2.prefix}eu-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.vpc2.eu.region}-b"
  metadata_startup_script   = local.eu_probe_init
  allow_stopping_for_update = true
  tags                      = [var.vpc2.vm_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.vpc2.eu_subnet.self_link
    network_ip = var.vpc2.eu.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "vpc2_asia_vm" {
  project                   = var.project_id_vpc1
  name                      = "${var.vpc2.prefix}asia-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.vpc2.asia.region}-b"
  metadata_startup_script   = local.asia_probe_init
  allow_stopping_for_update = true
  tags                      = [var.vpc2.vm_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.vpc2.asia_subnet.self_link
    network_ip = var.vpc2.asia.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "vpc2_us_vm" {
  project                   = var.project_id_vpc1
  name                      = "${var.vpc2.prefix}us-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.vpc2.us.region}-b"
  metadata_startup_script   = local.us_probe_init
  allow_stopping_for_update = true
  tags                      = [var.vpc2.vm_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.vpc2.us_subnet.self_link
    network_ip = var.vpc2.us.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
