
# instances
#---------------------------------------------
# vm1

resource "google_compute_instance" "gclb_vm1" {
  name                      = "${var.spoke1.prefix}gclb-vm1"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.region}-a"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true
  tags                      = [var.spoke1.gclb_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.subnet1.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# vm2

resource "google_compute_instance" "gclb_vm2" {
  name                      = "${var.spoke1.prefix}gclb-vm2"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.subnet1.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
