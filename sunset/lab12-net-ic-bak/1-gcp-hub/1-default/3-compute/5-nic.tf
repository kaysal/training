
# connectivity test instances
#-------------------------------------------

# eu

resource "google_compute_instance" "vpc1_eu_vm" {
  name                      = "vpc1-eu-vm"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  allow_stopping_for_update = true
  tags                      = ["lockdown", "deny-http"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.default.name
    network_ip = var.hub.default.eu.test_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

resource "google_compute_instance" "vpc1_us_vm" {
  name                      = "vpc1-us-vm"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  allow_stopping_for_update = true
  tags                      = ["deny-http"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.default.name
    network_ip = var.hub.default.us.test_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
