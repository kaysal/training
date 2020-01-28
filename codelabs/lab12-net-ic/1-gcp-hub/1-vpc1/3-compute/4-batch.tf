
# batch jobs
#-------------------------------------------

# eu

locals {
  batch_eu_init = templatefile("scripts/batch.sh.tpl", {
    TARGET = var.hub.vpc1.asia.ip.db
    n      = 10
    c      = 5
  })
}

resource "google_compute_instance" "batch_job_eu" {
  name                      = "batch-job-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.vpc1.eu.region}-c"
  allow_stopping_for_update = true
  tags                      = ["lockdown"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.image_eu_web.self_link
    }
  }

  network_interface {
    subnetwork = local.subnet.eu.batch.self_link
    network_ip = var.hub.vpc1.eu.ip.batch
  }

  metadata_startup_script = local.batch_eu_init

  service_account {
    scopes = ["cloud-platform"]
  }
}
