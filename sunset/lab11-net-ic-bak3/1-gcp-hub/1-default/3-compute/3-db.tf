
# db
#-------------------------------------------

# asia

resource "google_compute_instance" "db_asia" {
  name                      = "db-asia"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.asia.region}-b"
  allow_stopping_for_update = true
  tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.db_asia.self_link
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.asia.db_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# eu

resource "google_compute_instance" "db_eu" {
  name                      = "db-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  allow_stopping_for_update = true
  tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.db_eu.self_link
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.db_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

resource "google_compute_instance" "db_us" {
  name                      = "db-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  allow_stopping_for_update = true
  #tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.db_us.self_link
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.db_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
