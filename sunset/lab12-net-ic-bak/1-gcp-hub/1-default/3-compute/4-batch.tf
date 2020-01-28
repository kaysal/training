
# batch jobs
#-------------------------------------------

# eu

locals {
  batch_eu_init = templatefile("scripts/batch.sh.tpl", {
    TARGET = var.hub.default.asia.db_ip
    n      = 100
    c      = 10
  })
}

resource "google_compute_instance" "batch_job_eu" {
  name                      = "batch-job-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-c"
  allow_stopping_for_update = true
  tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image_eu_web.self_link
    }
  }

  network_interface {
    network    = local.default.name
    network_ip = var.hub.default.eu.batch_ip
  }

  metadata_startup_script = local.batch_eu_init

  service_account {
    scopes = ["cloud-platform"]
  }
}
