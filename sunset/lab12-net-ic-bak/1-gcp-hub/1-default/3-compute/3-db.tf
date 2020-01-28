
# db
#-------------------------------------------

# asia

locals {
  db_asia_init = templatefile("scripts/db.sh.tpl", {
    TARGET = var.hub.default.us.db_ip
    n      = 2
    c      = 1
  })
}

resource "google_compute_instance" "db_asia" {
  name                      = "db-asia"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.asia.region}-b"
  allow_stopping_for_update = true
  tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image_asia_web.self_link
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.asia.db_ip
  }

  metadata_startup_script = local.db_asia_init

  service_account {
    scopes = ["cloud-platform"]
  }
}

# eu

locals {
  db_eu_init = templatefile("scripts/db.sh.tpl", {
    TARGET = var.hub.default.us.db_ip
    n      = 2
    c      = 1
  })
}

resource "google_compute_instance" "db_eu" {
  name                      = "db-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  allow_stopping_for_update = true
  tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image_eu_web.self_link
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.db_ip
  }

  metadata_startup_script = local.db_eu_init

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

locals {
  db_us_init = templatefile("scripts/default.sh.tpl", {})
}

resource "google_compute_instance" "db_us" {
  name                      = "db-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  allow_stopping_for_update = true
  tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image_us_web.self_link
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.db_ip
  }

  metadata_startup_script = local.db_us_init

  service_account {
    scopes = ["cloud-platform"]
  }
}
