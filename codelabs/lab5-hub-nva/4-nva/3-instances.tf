
# test instance

locals {
  instance_init = templatefile("scripts/instance.sh.tpl", {})
}

resource "google_compute_instance" "nva_untrust_vm" {
  name                      = "${var.untrust.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.untrust_subnet.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

# compute image

resource "google_compute_image" "pfsense_244" {
  name   = "pfsense-244"
  family = "freebsd"

  raw_disk {
    source = var.global.image.pfsense_244
  }
}

# pfsense b

resource "google_compute_instance" "pfsense_b" {
  name                      = "${var.global.prefix}pfsense-b"
  machine_type              = var.global.machine_type
  zone                      = "europe-west1-b"
  can_ip_forward            = "true"
  allow_stopping_for_update = "true"
  tags                      = [var.global.tags.pfsense]

  metadata = {
    serial-port-enable = "true"
    ssh-keys           = "user:${file(var.global.public_key_path)}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = google_compute_subnetwork.untrust_subnet.self_link
    network_ip = var.untrust.pfsenseb_ip
    access_config {}
  }

  network_interface {
    subnetwork = google_compute_subnetwork.trust_subnet.self_link
    network_ip = var.trust.pfsenseb_ip
  }

  boot_disk {
    initialize_params {
      image = google_compute_image.pfsense_244.self_link
      size  = 100
    }
  }
}

# pfsense c

resource "google_compute_instance" "pfsense_c" {
  name                      = "${var.global.prefix}pfsense-c"
  machine_type              = var.global.machine_type
  zone                      = "europe-west1-c"
  can_ip_forward            = "true"
  allow_stopping_for_update = "true"
  tags                      = [var.global.tags.pfsense]

  metadata = {
    serial-port-enable = "true"
    ssh-keys           = "user:${file(var.global.public_key_path)}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = google_compute_subnetwork.untrust_subnet.self_link
    network_ip = var.untrust.pfsensec_ip
    access_config {
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.trust_subnet.self_link
    network_ip = var.trust.pfsensec_ip
  }

  boot_disk {
    initialize_params {
      image = google_compute_image.pfsense_244.self_link
      size  = 100
    }
  }
}
