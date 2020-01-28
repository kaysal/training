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
  instance_init = templatefile("scripts/instance.sh.tpl", {})
  web_init      = templatefile("scripts/web.sh.tpl", {})
  hub = {
    subnet_eu   = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet_eu
    subnet_asia = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet_asia
    subnet_u2   = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet_us
  }
  spoke1 = {
    subnet_eu   = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet_eu
    subnet_asia = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet_asia
    subnet_us   = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet_us
  }
  spoke2 = {
    subnet_eu   = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet_eu
    subnet_asia = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet_asia
    subnet_us   = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet_us
  }
}

# spoke1

resource "google_compute_instance" "spoke1_vm_eu" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}vm-eu"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.region_eu}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke1.gclb_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.subnet_eu.self_link
    network_ip = var.spoke1.vm_eu_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "spoke1_vm_asia" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}vm-asia"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.region_asia}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke1.gclb_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.subnet_asia.self_link
    network_ip = var.spoke1.vm_asia_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "spoke1_vm_us" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}vm-us"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.region_us}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke1.gclb_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.subnet_us.self_link
    network_ip = var.spoke1.vm_us_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# spoke2

resource "google_compute_instance" "spoke2_vm_eu" {
  project      = var.project_id_spoke2
  name         = "${var.spoke2.prefix}vm-eu"
  machine_type = var.global.machine_type
  zone         = "${var.spoke2.region_eu}-b"
  #metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true
  tags                      = [var.spoke2.vm_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.subnet_eu.self_link
    network_ip = var.spoke2.vm_eu_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "spoke2_vm_asia_1" {
  project                   = var.project_id_spoke2
  name                      = "${var.spoke2.prefix}vm-asia-1"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.region_asia}-b"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke2.ilb_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.subnet_asia.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_instance" "spoke2_vm_asia_2" {
  project                   = var.project_id_spoke2
  name                      = "${var.spoke2.prefix}vm-asia-2"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.region_asia}-c"
  metadata_startup_script   = local.web_init
  allow_stopping_for_update = true
  tags                      = [var.spoke2.ilb_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.subnet_asia.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
