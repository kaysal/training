
locals {
  instance_init = templatefile("scripts/startup.sh.tpl", {})
}

# eu1

resource "google_compute_instance" "vm_eu1" {
  name                      = "${var.orange.prefix}vm-eu1"
  machine_type              = var.global.machine_type
  zone                      = "${var.orange.eu1.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.eu1_cidr.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc_account.email
  }
}

# eu2

resource "google_compute_instance" "vm_eu2" {
  name                      = "${var.orange.prefix}vm-eu2"
  machine_type              = var.global.machine_type
  zone                      = "${var.orange.eu2.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.eu2_cidr.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc_account.email
  }
}
