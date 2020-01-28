
# db
#-------------------------------------------

# asia

resource "google_compute_instance" "db_asia" {
  name                      = "db-asia"
  machine_type              = var.global.machine_type
  zone                      = "${var.default.asia.region}-b"
  metadata_startup_script   = file("scripts/startup.sh")
  allow_stopping_for_update = true
  tags                      = ["external-db"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = google_compute_network.default.self_link
    network_ip = "10.140.0.6"
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# eu

resource "google_compute_instance" "db_eu" {
  name                      = "db-eu"
  machine_type              = var.global.machine_type
  zone                      = "${var.default.eu.region}-b"
  metadata_startup_script   = file("scripts/startup.sh")
  allow_stopping_for_update = true
  tags                      = ["external-db"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = google_compute_network.default.self_link
    network_ip = "10.132.0.2"
    #access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

resource "google_compute_instance" "db_us" {
  name                      = "db-us"
  machine_type              = var.global.machine_type
  zone                      = "${var.default.us.region}-c"
  metadata_startup_script   = file("scripts/startup.sh")
  allow_stopping_for_update = true
  tags                      = ["external-db"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = google_compute_network.default.self_link
    network_ip = "10.128.0.7"
    #access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
