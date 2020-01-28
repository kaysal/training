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
  vpc1 = {
    subnet_mirror    = data.terraform_remote_state.vpc.outputs.subnets.vpc1.subnet_mirror
    subnet_collector = data.terraform_remote_state.vpc.outputs.subnets.vpc1.subnet_collector
    network          = data.terraform_remote_state.vpc.outputs.networks.vpc1
  }
  vpc2 = {
    subnet_mirror = data.terraform_remote_state.vpc.outputs.subnets.vpc2.subnet_mirror
    network       = data.terraform_remote_state.vpc.outputs.networks.vpc2
  }
}

# compute image

resource "google_compute_image" "pfsense_2_4_4" {
  name   = "pfsense-2-4-4"
  family = "freebsd"

  raw_disk {
    source = var.global.image.pfsense_244
  }
}

# vpc1 vm instance

resource "google_compute_instance" "vpc1_vm" {
  name                      = "${var.vpc1.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.vpc1.region}-c"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.vpc1.subnet_mirror.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "user:${file(var.public_key_path)}"
  }
}

# pfsense instance

resource "google_compute_instance" "pfsense" {
  name                      = "${var.global.prefix}pfsense"
  machine_type              = var.global.machine_type
  zone                      = "${var.vpc1.region}-b"
  can_ip_forward            = true
  allow_stopping_for_update = true
  tags                      = ["collector"]

  network_interface {
    subnetwork = local.vpc1.subnet_collector.self_link
    network_ip = var.vpc1.pfsense_ip
    access_config {}
  }

  boot_disk {
    initialize_params {
      image = google_compute_image.pfsense_2_4_4.self_link
      size  = 100
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    serial-port-enable = true
  }
}

# vpc2 vm instance

resource "google_compute_instance" "vpc2_vm" {
  name                      = "${var.vpc2.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.vpc2.region}-c"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.vpc2.subnet_mirror.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "user:${file(var.public_key_path)}"
  }
}
