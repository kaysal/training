
# probe
#-------------------------------------------

# us

locals {
  probe_us_init = templatefile("scripts/probe.sh.tpl", {
    SITE = "en.wikipedia.org"
    ILB  = var.hub.default.us.ilb_vip
  })
}

resource "google_compute_instance" "probe_us" {
  name                      = "probe-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-b"
  metadata_startup_script   = local.probe_us_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.self_link
    network_ip = var.hub.default.us.probe_ip
    #access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
