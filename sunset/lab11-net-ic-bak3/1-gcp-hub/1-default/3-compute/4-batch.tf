
# batch jobs
#-------------------------------------------

# eu

resource "google_compute_instance" "batch_job_eu" {
  name                      = "batch-job-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-c"
  allow_stopping_for_update = true
  tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.batch_job_eu.self_link
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.batch_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# us

resource "google_compute_instance" "batch_job_us" {
  name                      = "batch-job-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-c"
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = data.google_compute_image.batch_job_us.self_link
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.us.batch_ip
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
