
# nat gateway instance

locals {
  natgw_init = templatefile("${path.module}/config/startup.sh.tpl", {
    TRUST_IP       = var.trust_ip
    TRUST_IP_DGW   = var.trust_ip_dgw
  })
}

resource "google_compute_instance" "natgw" {
  name                      = "${var.prefix}natgw"
  machine_type              = var.machine_type
  zone                      = var.zone
  allow_stopping_for_update = true
  can_ip_forward            = true
  #tags                      = var.natgw_tags

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = var.untrust_subnet
    network_ip = var.untrust_ip
    access_config {
      nat_ip = var.untrust_nat_ip
    }
  }

  network_interface {
    subnetwork = var.trust_subnet
    network_ip = var.trust_ip
  }

  metadata_startup_script = local.natgw_init

  service_account {
    scopes = ["cloud-platform"]
  }
}

# default route

resource "google_compute_route" "trust_default_route_natgw" {
  name                   = "${var.prefix}trust-default-route-natgw"
  dest_range             = "0.0.0.0/0"
  network                = var.vpc_trust
  next_hop_instance_zone = var.zone
  next_hop_instance      = google_compute_instance.natgw.name
  priority               = 100
  #tags                   = var.route_tags
}
