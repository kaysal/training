
# eu1 envoy proxy

locals {
  sidecar_proxy_eu1_init = templatefile("scripts/sidecar.sh.tpl", {
    ENVOY_USER         = "envoy"
    SERVICE_CIDR       = "*"
    GCP_PROJECT_NUMBER = data.google_project.project.number
    VPC_NETWORK_NAME   = local.svc.vpc.name
    ENVOY_PORT         = "15001"
    ENVOY_ADMIN_PORT   = "15000"
    LOG_DIR            = "/var/log/envoy/"
    LOG_LEVEL          = "info"
    XDS_SERVER_CERT    = "/etc/ssl/certs/ca-certificates.crt"
  })
}

resource "google_compute_instance" "sidecar_proxy_eu1" {
  project                   = var.project_id_svc
  name                      = "sidecar-proxy-eu1"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.eu1.region}-b"
  metadata_startup_script   = local.sidecar_proxy_eu1_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.eu1_cidr.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}

resource "google_compute_route" "svc_proxy_eu1_route" {
  name                   = "svc-proxy-eu1-route"
  dest_range             = "10.10.10.10/32"
  network                = local.svc.vpc.self_link
  next_hop_instance_zone = "${var.hub.eu1.region}-b"
  next_hop_instance      = google_compute_instance.sidecar_proxy_eu1.name
  priority               = 100
}

# asia1 envoy proxy

locals {
  sidecar_proxy_asia1_init = templatefile("scripts/sidecar.sh.tpl", {
    ENVOY_USER         = "envoy"
    SERVICE_CIDR       = "*"
    GCP_PROJECT_NUMBER = data.google_project.project.number
    VPC_NETWORK_NAME   = local.svc.vpc.name
    ENVOY_PORT         = "15001"
    ENVOY_ADMIN_PORT   = "15000"
    LOG_DIR            = "/var/log/envoy/"
    LOG_LEVEL          = "info"
    XDS_SERVER_CERT    = "/etc/ssl/certs/ca-certificates.crt"
  })
}

resource "google_compute_instance" "sidecar_proxy_asia1" {
  project                   = var.project_id_svc
  name                      = "sidecar-proxy-asia1"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.asia1.region}-b"
  metadata_startup_script   = local.sidecar_proxy_asia1_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.asia1_cidr.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}


# us1 envoy proxy

locals {
  sidecar_proxy_us1_init = templatefile("scripts/sidecar.sh.tpl", {
    ENVOY_USER         = "envoy"
    SERVICE_CIDR       = "*"
    GCP_PROJECT_NUMBER = data.google_project.project.number
    VPC_NETWORK_NAME   = local.svc.vpc.name
    ENVOY_PORT         = "15001"
    ENVOY_ADMIN_PORT   = "15000"
    LOG_DIR            = "/var/log/envoy/"
    LOG_LEVEL          = "info"
    XDS_SERVER_CERT    = "/etc/ssl/certs/ca-certificates.crt"
  })
}

resource "google_compute_instance" "sidecar_proxy_us1" {
  project                   = var.project_id_svc
  name                      = "sidecar-proxy-us1"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.us1.region}-b"
  metadata_startup_script   = local.sidecar_proxy_us1_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.svc.us1_cidr.self_link
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.svc.svc_account.email
  }
}
