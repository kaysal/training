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
  hub = {
    network     = data.terraform_remote_state.vpc.outputs.networks.hub.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.hub.us_subnet
  }
}

# hub

locals {
  eu_probe_init = templatefile("scripts/probe.sh.tpl", {
    TARGET1 = data.terraform_remote_state.gclb.outputs.address.spoke1.gclb.address
    TARGET2 = var.hub.us.vm_ip
    TARGET3 = "google.com"
  })
  asia_probe_init = templatefile("scripts/probe.sh.tpl", {
    TARGET1 = data.terraform_remote_state.gclb.outputs.address.spoke1.gclb.address
    TARGET2 = data.terraform_remote_state.ilb.outputs.address.spoke2.ilb.address
    TARGET3 = var.hub.us.vm_ip
  })
  us_probe_init = templatefile("scripts/probe.sh.tpl", {
    TARGET1 = data.terraform_remote_state.gclb.outputs.address.spoke1.gclb.address
    TARGET2 = var.hub.eu.vm_ip
    TARGET3 = var.hub.asia.vm_ip
  })
}

resource "google_compute_instance" "hub_eu_vm" {
  project                   = var.project_id_spoke1
  name                      = "${var.hub.prefix}eu-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.eu.region}-b"
  metadata_startup_script   = local.eu_probe_init
  allow_stopping_for_update = true
  tags                      = [var.hub.vm_tag, var.hub.proxy_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.eu_subnet.self_link
    network_ip = var.hub.eu.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "hub_asia_vm" {
  project                   = var.project_id_spoke1
  name                      = "${var.hub.prefix}asia-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.asia.region}-b"
  metadata_startup_script   = local.asia_probe_init
  allow_stopping_for_update = true
  tags                      = [var.hub.vm_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.asia_subnet.self_link
    network_ip = var.hub.asia.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "hub_us_vm" {
  project                   = var.project_id_spoke1
  name                      = "${var.hub.prefix}us-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.us.region}-b"
  metadata_startup_script   = local.us_probe_init
  allow_stopping_for_update = true
  tags                      = [var.hub.vm_tag, var.hub.proxy_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.us_subnet.self_link
    network_ip = var.hub.us.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
