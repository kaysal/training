
# probe
#-------------------------------------------
/*
# asia

locals {
  probe_asia_init = templatefile("scripts/probe.sh.tpl", {
    SMTP_PROXY = local.smtp_tcp_proxy_vip.address
    GCLB       = local.gclb_vip.address
    GCLB_STD   = local.gclb_vip_standard.address
    GCLB_PREM  = local.gclb_vip_premium.address
    HOST       = var.global.app_host
  })
}

resource "google_compute_instance" "probe_asia" {
  name                      = "probe-asia"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.asia.region}-b"
  metadata_startup_script   = local.probe_asia_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.self_link
    network_ip = var.hub.default.asia.probe_ip
    access_config {
      nat_ip = local.probe_asia_nat_ip.address
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# eu

locals {
  probe_eu_init = templatefile("scripts/probe.sh.tpl", {
    SMTP_PROXY = local.smtp_tcp_proxy_vip.address
    GCLB       = local.gclb_vip.address
    GCLB_STD   = local.gclb_vip_standard.address
    GCLB_PREM  = local.gclb_vip_premium.address
    HOST       = var.global.app_host
  })
}

resource "google_compute_instance" "probe_eu" {
  name                      = "probe-eu"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.eu.region}-b"
  metadata_startup_script   = local.probe_eu_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.self_link
    network_ip = var.hub.default.eu.probe_ip
    access_config {
      nat_ip = local.probe_eu_nat_ip.address
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
*/
# us

locals {
  probe_us_init = templatefile("scripts/probe.sh.tpl", {
    SMTP_PROXY = local.smtp_tcp_proxy_vip.address
    GCLB       = local.gclb_vip.address
    GCLB_STD   = local.gclb_vip_standard.address
    GCLB_PREM  = local.gclb_vip_premium.address
    HOST       = var.global.app_host
  })
}

resource "google_compute_instance" "probe_us" {
  name                      = "probe-us"
  machine_type              = var.global.standard_machine
  zone                      = "${var.hub.default.us.region}-b"
  metadata_startup_script   = local.probe_us_init
  allow_stopping_for_update = true
  tags                      = ["web"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    network    = local.default.self_link
    network_ip = var.hub.default.us.probe_ip
    access_config {
      nat_ip = local.probe_us_nat_ip.address
    }
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
