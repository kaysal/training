
# vm instance

locals {
  instance_init = templatefile("scripts/startup.sh.tpl", {})
}

resource "google_compute_instance" "west_vm" {
  name                      = "${var.west.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.west.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.west_subnet.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
