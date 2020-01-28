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
  untrust = {
    subnet1 = data.terraform_remote_state.vpc.outputs.subnets.untrust.subnet1
    network = data.terraform_remote_state.vpc.outputs.networks.untrust
  }
  trust = {
    subnet1 = data.terraform_remote_state.vpc.outputs.subnets.trust.subnet1
    subnet2 = data.terraform_remote_state.vpc.outputs.subnets.trust.subnet2
    network = data.terraform_remote_state.vpc.outputs.networks.trust
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

# vm instances

resource "google_compute_instance" "untrust_vm" {
  name                      = "${var.untrust.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.untrust.region}-d"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.untrust.subnet1.self_link
    network_ip = var.untrust.vm_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "user:${file(var.public_key_path)}"
  }
}

# Create pfsense VM

resource "google_compute_instance" "pfsense" {
  name                      = "${var.global.prefix}pfsense"
  machine_type              = var.global.machine_type
  zone                      = "${var.untrust.region}-b"
  min_cpu_platform          = var.global.min_machine_cpu_fw
  can_ip_forward            = true
  allow_stopping_for_update = true
  tags                      = ["collector"]

  network_interface {
    subnetwork = local.untrust.subnet1.self_link
    network_ip = var.untrust.pfsense_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.trust.subnet1.self_link
    network_ip = var.trust.pfsense_ip
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

resource "google_compute_instance" "trust_vm" {
  name                      = "${var.trust.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.trust.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true
  tags                      = ["pfsense"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.trust.subnet1.self_link
    network_ip = var.trust.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "user:${file(var.public_key_path)}"
  }
}

resource "google_compute_instance" "trust_vm_solo" {
  name                      = "${var.trust.prefix}vm-solo"
  machine_type              = var.global.machine_type
  zone                      = "${var.trust.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.trust.subnet2.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata = {
    ssh-keys = "user:${file(var.public_key_path)}"
  }
}

# default route

resource "google_compute_route" "default_route" {
  name                   = "${var.global.prefix}default-route"
  dest_range             = "0.0.0.0/0"
  network                = local.trust.network.self_link
  next_hop_instance_zone = "europe-west1-b"
  next_hop_instance      = google_compute_instance.pfsense.name
  priority               = 100
  tags                   = ["pfsense"]
}
