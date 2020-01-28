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
  hub = {
    network     = data.terraform_remote_state.vpc.outputs.networks.hub.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.hub.us_subnet
  }
  spoke1 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.spoke1.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.asia_subnet
    us_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.us_subnet
  }
  spoke2 = {
    network     = data.terraform_remote_state.vpc.outputs.networks.spoke2.network
    eu_subnet   = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.eu_subnet
    asia_subnet = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.asia_subnet
  }
}

# spoke1

resource "google_compute_instance" "spoke1_eu_vm" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}eu-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.eu.region}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke1.hc_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.eu_subnet.self_link
    network_ip = var.spoke1.eu.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "spoke1_asia_vm" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}asia-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.asia.region}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke1.hc_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.asia_subnet.self_link
    network_ip = var.spoke1.asia.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "spoke1_us_vm" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}us-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.us.region}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke1.hc_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.us_subnet.self_link
    network_ip = var.spoke1.us.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# spoke2

resource "google_compute_instance" "spoke2_eu_vm" {
  project      = var.project_id_spoke2
  name         = "${var.spoke2.prefix}eu-vm"
  machine_type = var.global.machine_type
  zone         = "${var.spoke2.eu.region}-b"
  #metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke2.vm_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.eu_subnet.self_link
    network_ip = var.spoke2.eu.vm_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "spoke2_asia_vm1" {
  project                   = var.project_id_spoke2
  name                      = "${var.spoke2.prefix}asia-vm1"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.asia.region}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke2.hc_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.asia_subnet.self_link
    network_ip = var.spoke2.asia.vm_ip1
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "spoke2_asia_vm2" {
  project                   = var.project_id_spoke2
  name                      = "${var.spoke2.prefix}asia-vm2"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.asia.region}-c"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke2.hc_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.asia_subnet.self_link
    network_ip = var.spoke2.asia.vm_ip2
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
