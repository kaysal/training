
# onprem
#---------------------------------------------

# eu vm

resource "google_compute_instance" "onprem_vm_eu" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}vm-eu"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.eu.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.eu_cidr.self_link
    network_ip = var.onprem.eu.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# eu unbound dns server

locals {
  unbound_init = templatefile("scripts/unbound.sh.tpl", {
    NAME_LAB_ONPREM_PROXY_IP   = "proxy.eu.onprem.lab"
    RECORD_LAB_ONPREM_PROXY_IP = var.onprem.eu.proxy_ip
    NAME_LAB_ONPREM_VM_ASIA    = "vm.asia.onprem.lab"
    RECORD_LAB_ONPREM_VM_ASIA  = var.onprem.asia.vm_ip
    NAME_LAB_ONPREM_VM_US      = "vm.us.onprem.lab"
    RECORD_LAB_ONPREM_VM_US    = var.onprem.us.vm_ip
    EGRESS_PROXY               = "35.199.192.0/19"
  })
}

resource "google_compute_instance" "onprem_unbound" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}unbound"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.eu.region}-b"
  metadata_startup_script   = local.unbound_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.eu_cidr.self_link
    network_ip = var.onprem.eu.unbound_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# proxy for forwarding dns queries to hub

locals {
  onprem_proxy_init = templatefile("scripts/proxy-onprem.sh.tpl", {
    ONPREM_EU1_PROXY    = "${var.onprem.eu.proxy_eu1_ip}"
    HUB_EU1_DNS_INBOUND = "${var.hub.eu1.dns_inbound_ip}"
  })
}

resource "google_compute_instance" "onprem_dns_proxy" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}proxy"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.eu.region}-c"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.onprem_proxy_init

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.eu_cidr.self_link
    network_ip = var.onprem.eu.proxy_ip
    access_config {}

    alias_ip_range {
      subnetwork_range_name = "dns-range"
      ip_cidr_range         = "${var.onprem.eu.proxy_eu1_ip}/32"
    }
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# asia vm

resource "google_compute_instance" "onprem_vm_asia" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}vm-asia"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.asia.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.asia_cidr.self_link
    network_ip = var.onprem.asia.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# vm_us

resource "google_compute_instance" "onprem_vm_us" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}vm-us"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.us.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.us_cidr.self_link
    network_ip = var.onprem.us.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}
