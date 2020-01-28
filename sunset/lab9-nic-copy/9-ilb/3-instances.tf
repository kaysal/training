
# instances
#---------------------------------------------
# vm1

resource "google_compute_instance" "ilb_vm1" {
  name                      = "${var.spoke2.prefix}ilb-vm1"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true
  tags                      = [var.spoke2.ilb_tag]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.subnet1.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# vm2

resource "google_compute_instance" "ilb_vm2" {
  name                      = "${var.spoke2.prefix}ilb-vm2"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.region}-c"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.subnet1.self_link
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
