
# eu
#---------------------------------------------

# eu1

resource "google_compute_instance" "svc_vm_eu1" {
  project                   = var.project_id_svc
  name                      = "${var.svc.prefix}vm-eu1"
  machine_type              = var.global.machine_type
  zone                      = "${var.svc.eu1.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.eu1_cidr.self_link
    network_ip = var.svc.eu1.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}

# eu2

resource "google_compute_instance" "svc_vm_eu2" {
  project                   = var.project_id_svc
  name                      = "${var.svc.prefix}vm-eu2"
  machine_type              = var.global.machine_type
  zone                      = "${var.svc.eu2.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.eu2_cidr.self_link
    network_ip = var.svc.eu2.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}

# asia
#---------------------------------------------

# asia1

resource "google_compute_instance" "svc_vm_asia1" {
  project                   = var.project_id_svc
  name                      = "${var.svc.prefix}vm-asia1"
  machine_type              = var.global.machine_type
  zone                      = "${var.svc.asia1.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.asia1_cidr.self_link
    network_ip = var.svc.asia1.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}

# asia2

resource "google_compute_instance" "svc_vm_asia2" {
  project                   = var.project_id_svc
  name                      = "${var.svc.prefix}vm-asia2"
  machine_type              = var.global.machine_type
  zone                      = "${var.svc.asia2.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.asia2_cidr.self_link
    network_ip = var.svc.asia2.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}


# us
#---------------------------------------------

# us1

resource "google_compute_instance" "svc_vm_us1" {
  project                   = var.project_id_svc
  name                      = "${var.svc.prefix}vm-us1"
  machine_type              = var.global.machine_type
  zone                      = "${var.svc.us1.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.us1_cidr.self_link
    network_ip = var.svc.us1.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}

# us2

resource "google_compute_instance" "svc_vm_us2" {
  project                   = var.project_id_svc
  name                      = "${var.svc.prefix}vm-us2"
  machine_type              = var.global.machine_type
  zone                      = "${var.svc.us2.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.us2_cidr.self_link
    network_ip = var.svc.us2.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}
