
# connectivity test instances
#-------------------------------------------

# eu

resource "google_compute_instance" "vpc1_eu_vm" {
  name                      = "vpc1-eu-vm"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.vpc1.eu.region}-b"
  allow_stopping_for_update = true
  tags                      = ["lockdown", "deny-http"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.subnet.eu.nic.self_link
    network_ip = var.hub.vpc1.eu.ip.nic
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

resource "google_compute_instance" "vpc1_us_vm" {
  name                      = "vpc1-us-vm"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.vpc1.us.region}-c"
  allow_stopping_for_update = true
  tags                      = ["lockdown", "deny-http"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.subnet.us.nic.self_link
    network_ip = var.hub.vpc1.us.ip.nic
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
