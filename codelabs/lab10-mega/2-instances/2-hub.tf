
# proxy eu1
#---------------------------------------------

# instance

locals {
  hub_eu1_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    HUB_PROXY       = var.hub.eu1.proxy_ip
    ONPREM_UNBOUND  = var.onprem.eu.unbound_ip
    PROXY_IPX       = var.hub.eu1.proxy_ipx
    DGW_IPX         = var.hub.eu1.dgw_ipx
    SVC_EU1_CIDR    = var.svc.eu1.cidr
    SVC_EU2_CIDR    = var.svc.eu2.cidr
    SVC_ASIA1_CIDR  = var.svc.asia1.cidr
    SVC_ASIA2_CIDR  = var.svc.asia2.cidr
    SVC_US1_CIDR    = var.svc.us1.cidr
    SVC_US2_CIDR    = var.svc.us2.cidr
    TRAFFIC_DIR_VIP = var.svc.us2.cidr
  })
}

resource "google_compute_instance" "hub_proxy_eu1" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-eu1"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.eu1.region}-b"
  metadata_startup_script   = local.hub_eu1_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.eu1_cidr.self_link
    network_ip = var.hub.eu1.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.eu1_cidrx.self_link
    network_ip = var.hub.eu1.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# routes

resource "google_compute_route" "hub_eu1_route_to_svc" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu1-route-to-svc"
  dest_range             = "10.9.0.0/16"
  network                = local.hub.vpc_eu1.self_link
  next_hop_instance_zone = "${var.hub.eu1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu1.name
  priority               = 100
}

resource "google_compute_route" "hub_eu1x_route_to_host_eu1" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu1x-route-to-host-eu1"
  dest_range             = var.hub.eu1.cidr
  network                = local.hub.vpc_eu1x.self_link
  next_hop_instance_zone = "${var.hub.eu1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu1.name
  priority               = 100
}

resource "google_compute_route" "hub_eu1x_route_to_onprem_eu" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu1x-route-to-onprem-eu"
  dest_range             = var.onprem.eu.cidr
  network                = local.hub.vpc_eu1x.self_link
  next_hop_instance_zone = "${var.hub.eu1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu1.name
  priority               = 100
}


# proxy eu2
#---------------------------------------------

# instance

locals {
  hub_eu2_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    HUB_PROXY       = var.hub.eu2.proxy_ip
    ONPREM_UNBOUND  = var.onprem.eu.unbound_ip
    PROXY_IPX       = var.hub.eu2.proxy_ipx
    DGW_IPX         = var.hub.eu2.dgw_ipx
    SVC_EU1_CIDR    = var.svc.eu1.cidr
    SVC_EU2_CIDR    = var.svc.eu2.cidr
    SVC_ASIA1_CIDR  = var.svc.asia1.cidr
    SVC_ASIA2_CIDR  = var.svc.asia2.cidr
    SVC_US1_CIDR    = var.svc.us1.cidr
    SVC_US2_CIDR    = var.svc.us2.cidr
    TRAFFIC_DIR_VIP = var.svc.us2.cidr
  })
}

resource "google_compute_instance" "hub_proxy_eu2" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-eu2"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.eu2.region}-b"
  metadata_startup_script   = local.hub_eu2_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.eu2_cidr.self_link
    network_ip = var.hub.eu2.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.eu2_cidrx.self_link
    network_ip = var.hub.eu2.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# routes

resource "google_compute_route" "hub_eu2_route_to_svc" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu2-route-to-svc"
  dest_range             = "10.9.0.0/16"
  network                = local.hub.vpc_eu2.self_link
  next_hop_instance_zone = "${var.hub.eu2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu2.name
  priority               = 100
}

resource "google_compute_route" "hub_eu2x_route_to_host_eu2" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu2x-route-to-host-eu2"
  dest_range             = var.hub.eu2.cidr
  network                = local.hub.vpc_eu2x.self_link
  next_hop_instance_zone = "${var.hub.eu2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu2.name
  priority               = 100
}

resource "google_compute_route" "hub_eu2x_route_to_onprem_eu" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}eu2x-route-to-onprem-eu"
  dest_range             = var.onprem.eu.cidr
  network                = local.hub.vpc_eu2x.self_link
  next_hop_instance_zone = "${var.hub.eu2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_eu2.name
  priority               = 100
}


# proxy asia1
#---------------------------------------------

# instance

locals {
  hub_asia1_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    HUB_PROXY       = var.hub.asia1.proxy_ip
    ONPREM_UNBOUND  = var.onprem.eu.unbound_ip
    PROXY_IPX       = var.hub.asia1.proxy_ipx
    DGW_IPX         = var.hub.asia1.dgw_ipx
    SVC_EU1_CIDR    = var.svc.eu1.cidr
    SVC_EU2_CIDR    = var.svc.eu2.cidr
    SVC_ASIA1_CIDR  = var.svc.asia1.cidr
    SVC_ASIA2_CIDR  = var.svc.asia2.cidr
    SVC_US1_CIDR    = var.svc.us1.cidr
    SVC_US2_CIDR    = var.svc.us2.cidr
    TRAFFIC_DIR_VIP = var.svc.us2.cidr
  })
}

resource "google_compute_instance" "hub_proxy_asia1" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-asia1"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.asia1.region}-b"
  metadata_startup_script   = local.hub_asia1_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.asia1_cidr.self_link
    network_ip = var.hub.asia1.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.asia1_cidrx.self_link
    network_ip = var.hub.asia1.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# routes

resource "google_compute_route" "hub_asia1_route_to_svc" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia1-route-to-svc"
  dest_range             = "10.9.0.0/16"
  network                = local.hub.vpc_asia1.self_link
  next_hop_instance_zone = "${var.hub.asia1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia1.name
  priority               = 100
}

resource "google_compute_route" "hub_asia1x_route_to_host_asia1" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia1x-route-to-host-asia1"
  dest_range             = var.hub.asia1.cidr
  network                = local.hub.vpc_asia1x.self_link
  next_hop_instance_zone = "${var.hub.asia1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia1.name
  priority               = 100
}

resource "google_compute_route" "hub_asia1x_route_to_onprem_asia" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia1x-route-to-onprem-asia"
  dest_range             = var.onprem.asia.cidr
  network                = local.hub.vpc_asia1x.self_link
  next_hop_instance_zone = "${var.hub.asia1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia1.name
  priority               = 100
}


# proxy asia2
#---------------------------------------------

# instance

locals {
  hub_asia2_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    HUB_PROXY       = var.hub.asia2.proxy_ip
    ONPREM_UNBOUND  = var.onprem.eu.unbound_ip
    PROXY_IPX       = var.hub.asia2.proxy_ipx
    DGW_IPX         = var.hub.asia2.dgw_ipx
    SVC_EU1_CIDR    = var.svc.eu1.cidr
    SVC_EU2_CIDR    = var.svc.eu2.cidr
    SVC_ASIA1_CIDR  = var.svc.asia1.cidr
    SVC_ASIA2_CIDR  = var.svc.asia2.cidr
    SVC_US1_CIDR    = var.svc.us1.cidr
    SVC_US2_CIDR    = var.svc.us2.cidr
    TRAFFIC_DIR_VIP = var.svc.us2.cidr
  })
}

resource "google_compute_instance" "hub_proxy_asia2" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-asia2"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.asia2.region}-b"
  metadata_startup_script   = local.hub_asia2_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.asia2_cidr.self_link
    network_ip = var.hub.asia2.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.asia2_cidrx.self_link
    network_ip = var.hub.asia2.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# routes

resource "google_compute_route" "hub_asia2_route_to_svc" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia2-route-to-svc"
  dest_range             = "10.9.0.0/16"
  network                = local.hub.vpc_asia2.self_link
  next_hop_instance_zone = "${var.hub.asia2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia2.name
  priority               = 100
}

resource "google_compute_route" "hub_asia2x_route_to_host_asia2" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia2x-route-to-host-asia2"
  dest_range             = var.hub.asia2.cidr
  network                = local.hub.vpc_asia2x.self_link
  next_hop_instance_zone = "${var.hub.asia2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia2.name
  priority               = 100
}

resource "google_compute_route" "hub_asia2x_route_to_onprem_asia" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}asia2x-route-to-onprem-asia"
  dest_range             = var.onprem.asia.cidr
  network                = local.hub.vpc_asia2x.self_link
  next_hop_instance_zone = "${var.hub.asia2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_asia2.name
  priority               = 100
}


# proxy us1
#---------------------------------------------

# instance

locals {
  hub_us1_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    HUB_PROXY       = var.hub.us1.proxy_ip
    ONPREM_UNBOUND  = var.onprem.eu.unbound_ip
    PROXY_IPX       = var.hub.us1.proxy_ipx
    DGW_IPX         = var.hub.us1.dgw_ipx
    SVC_EU1_CIDR    = var.svc.eu1.cidr
    SVC_EU2_CIDR    = var.svc.eu2.cidr
    SVC_ASIA1_CIDR  = var.svc.asia1.cidr
    SVC_ASIA2_CIDR  = var.svc.asia2.cidr
    SVC_US1_CIDR    = var.svc.us1.cidr
    SVC_US2_CIDR    = var.svc.us2.cidr
    TRAFFIC_DIR_VIP = var.svc.us2.cidr
  })
}

resource "google_compute_instance" "hub_proxy_us1" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-us1"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.us1.region}-b"
  metadata_startup_script   = local.hub_us1_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.us1_cidr.self_link
    network_ip = var.hub.us1.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.us1_cidrx.self_link
    network_ip = var.hub.us1.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# routes

resource "google_compute_route" "hub_us1_route_to_svc" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us1-route-to-svc"
  dest_range             = "10.9.0.0/16"
  network                = local.hub.vpc_us1.self_link
  next_hop_instance_zone = "${var.hub.us1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us1.name
  priority               = 100
}

resource "google_compute_route" "hub_us1x_route_to_host_us1" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us1x-route-to-host-us1"
  dest_range             = var.hub.us1.cidr
  network                = local.hub.vpc_us1x.self_link
  next_hop_instance_zone = "${var.hub.us1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us1.name
  priority               = 100
}

resource "google_compute_route" "hub_us1x_route_to_onprem_us" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us1x-route-to-onprem-us"
  dest_range             = var.onprem.us.cidr
  network                = local.hub.vpc_us1x.self_link
  next_hop_instance_zone = "${var.hub.us1.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us1.name
  priority               = 100
}


# proxy us2
#---------------------------------------------

# instance

locals {
  hub_us2_proxy_init = templatefile("scripts/proxy-hub.sh.tpl", {
    HUB_PROXY       = var.hub.us2.proxy_ip
    ONPREM_UNBOUND  = var.onprem.eu.unbound_ip
    PROXY_IPX       = var.hub.us2.proxy_ipx
    DGW_IPX         = var.hub.us2.dgw_ipx
    SVC_EU1_CIDR    = var.svc.eu1.cidr
    SVC_EU2_CIDR    = var.svc.eu2.cidr
    SVC_ASIA1_CIDR  = var.svc.asia1.cidr
    SVC_ASIA2_CIDR  = var.svc.asia2.cidr
    SVC_US1_CIDR    = var.svc.us1.cidr
    SVC_US2_CIDR    = var.svc.us2.cidr
    TRAFFIC_DIR_VIP = var.svc.us2.cidr
  })
}

resource "google_compute_instance" "hub_proxy_us2" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy-us2"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.us2.region}-b"
  metadata_startup_script   = local.hub_us2_proxy_init
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.us2_cidr.self_link
    network_ip = var.hub.us2.proxy_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.hub.us2_cidrx.self_link
    network_ip = var.hub.us2.proxy_ipx
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# routes

resource "google_compute_route" "hub_us2_route_to_svc" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us2-route-to-svc"
  dest_range             = "10.9.0.0/16"
  network                = local.hub.vpc_us2.self_link
  next_hop_instance_zone = "${var.hub.us2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us2.name
  priority               = 100
}

resource "google_compute_route" "hub_us2x_route_to_host_us2" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us2x-route-to-host-us2"
  dest_range             = var.hub.us2.cidr
  network                = local.hub.vpc_us2x.self_link
  next_hop_instance_zone = "${var.hub.us2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us2.name
  priority               = 100
}

resource "google_compute_route" "hub_us2x_route_to_onprem_us" {
  project                = var.project_id_hub
  name                   = "${var.hub.prefix}us2x-route-to-onprem-us"
  dest_range             = var.onprem.us.cidr
  network                = local.hub.vpc_us2x.self_link
  next_hop_instance_zone = "${var.hub.us2.region}-b"
  next_hop_instance      = google_compute_instance.hub_proxy_us2.name
  priority               = 100
}
