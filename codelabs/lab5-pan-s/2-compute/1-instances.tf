
# onprem
#---------------------------------------------

resource "google_compute_instance" "onprem_vm" {
  name                      = "${var.onprem.prefix}vm"
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
    subnetwork = local.onprem.subnet
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}

/*
# Internet NAT GW

locals {
  onprem_natgw_init = templatefile("scripts/natgw.sh.tpl", {
    #NATGW_IP  = "${var.onprem.dns_proxy_ip}"
  })
}

resource "google_compute_instance" "onprem_natgw" {
  name                      = "${var.onprem.prefix}natgw"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region}-d"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.onprem_natgw_init

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet
    network_ip = var.onprem.natgw_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_compute_instance.pan_b,
    google_compute_instance.pan_b,
  ]
}


# untrust

resource "google_compute_instance" "untrust_vm" {
  name                      = "${var.untrust.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.untrust.region}-d"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.untrust.subnet
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_compute_instance.pan_b,
    google_compute_instance.pan_b,
  ]
}*/

# pan
#---------------------------------------------

# pan b

resource "google_compute_instance" "pan_b" {
  name                      = "${var.global.prefix}pan-b"
  machine_type              = var.global.machine_type_fw
  zone                      = "europe-west1-b"
  min_cpu_platform          = var.global.min_machine_cpu_fw
  can_ip_forward            = true
  allow_stopping_for_update = true
  tags                      = [var.global.tags.pan]

  metadata = {
    mgmt-interface-swap = "enable"
    serial-port-enable  = true
    ssh-keys            = "user:${file(var.global.public_key_path)}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  // Swapped Interface for Load Balancer
  # before swap:
  # nic0 -> untrust -> eth1/0 [PAN MGT]
  # nic1 -> mgt -> eth1/1 [PAN UNTRUST]
  # nic2 -> trust -> eth1/1 [PAN TRUST]
  # after swap:
  # nic0 -> untrust -> eth1/1 [PAN UNTRUST]
  # nic1 -> mgt -> eth1/0 [PAN MGT]
  # nic2 -> trust -> eth1/1 [PAN TRUST]

  network_interface {
    subnetwork = local.untrust.subnet
    network_ip = var.untrust.panb_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.mgt.subnet
    network_ip = var.mgt.panb_ip
    access_config {
    }
  }

  network_interface {
    subnetwork = local.trust.subnet
    network_ip = var.trust.panb_ip
  }

  boot_disk {
    initialize_params {
      image = var.global.image.pan
    }
  }
}

# pan c

resource "google_compute_instance" "pan_c" {
  name                      = "${var.global.prefix}pan-c"
  machine_type              = var.global.machine_type_fw
  zone                      = "europe-west1-c"
  min_cpu_platform          = var.global.min_machine_cpu_fw
  can_ip_forward            = true
  allow_stopping_for_update = true
  tags                      = [var.global.tags.pan]

  metadata = {
    mgmt-interface-swap = "enable"
    serial-port-enable  = true
    ssh-keys            = "user:${file(var.global.public_key_path)}"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  // Swapped Interface for Load Balancer
  # before swap:
  # nic0 -> untrust -> eth1/0 [PAN MGT]
  # nic1 -> mgt -> eth1/1 [PAN UNTRUST]
  # nic2 -> trust -> eth1/1 [PAN TRUST]
  # after swap:
  # nic0 -> untrust -> eth1/1 [PAN UNTRUST]
  # nic1 -> mgt -> eth1/0 [PAN MGT]
  # nic2 -> trust -> eth1/1 [PAN TRUST]

  network_interface {
    subnetwork = local.untrust.subnet
    network_ip = var.untrust.panc_ip
    access_config {
    }
  }

  network_interface {
    subnetwork = local.mgt.subnet
    network_ip = var.mgt.panc_ip
    access_config {}
  }

  network_interface {
    subnetwork = local.trust.subnet
    network_ip = var.trust.panc_ip
  }

  boot_disk {
    initialize_params {
      image = var.global.image.pan
    }
  }
}

# zone1
#---------------------------------------------

resource "google_compute_instance" "zone1_vm" {
  name                      = "${var.zone1.prefix}vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.zone1.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.zone1.subnet
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }
}
/*
# PAN CONFIGURATION
#---------------------------------------------

# internet gateway routes

resource "google_compute_route" "trust_route_b" {
  name                   = "${var.global.prefix}trust-route-b"
  dest_range             = "0.0.0.0/0"
  network                = local.trust.network
  next_hop_instance_zone = "europe-west1-b"
  next_hop_instance      = "${google_compute_instance.pan_b.name}"
  priority               = 100
}

resource "google_compute_route" "trust_route_c" {
  name                   = "${var.global.prefix}trust-route-c"
  dest_range             = "0.0.0.0/0"
  network                = local.trust.network
  next_hop_instance_zone = "europe-west1-c"
  next_hop_instance      = "${google_compute_instance.pan_c.name}"
  priority               = 100
}

# ilb regional instance group

resource "google_compute_instance_group" "ig_b" {
  name      = "${var.global.prefix}ig-b"
  instances = [google_compute_instance.pan_b.self_link]
  zone      = "europe-west1-b"

  named_port {
    name = "http-80"
    port = "80"
  }

  named_port {
    name = "http-8080"
    port = "8080"
  }
}

resource "google_compute_instance_group" "ig_c" {
  name      = "${var.global.prefix}ig-c"
  instances = [google_compute_instance.pan_c.self_link]
  zone      = "europe-west1-c"

  named_port {
    name = "http-80"
    port = "80"
  }

  named_port {
    name = "http-8080"
    port = "8080"
  }
}

# health check

resource "google_compute_health_check" "hc_80" {
  name = "${var.global.prefix}hc-80"

  http_health_check {
    host         = "google-hc-80"
    port         = 80
    request_path = "/app80/"
  }
}

resource "google_compute_health_check" "hc_8080" {
  name = "${var.global.prefix}hc-8080"

  http_health_check {
    host         = "google-hc-8080"
    port         = 8080
    request_path = "/app8080/"
  }
}

# backends

# application on port 80

resource "google_compute_region_backend_service" "be_svc_80" {
  name             = "${var.global.prefix}be-svc-80"
  region           = "europe-west1"
  protocol         = "TCP"
  session_affinity = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.ig_b.self_link
  }

  backend {
    group = google_compute_instance_group.ig_c.self_link
  }

  health_checks = [google_compute_health_check.hc_80.self_link]
}

# application on port 8080

resource "google_compute_region_backend_service" "be_svc_8080" {
  name             = "${var.global.prefix}be-svc-8080"
  region           = "europe-west1"
  protocol         = "TCP"
  session_affinity = "CLIENT_IP"

  backend {
    group = google_compute_instance_group.ig_b.self_link
  }

  backend {
    group = google_compute_instance_group.ig_c.self_link
  }

  health_checks = [google_compute_health_check.hc_8080.self_link]
}

# Internal forwarding rules.
# Separate FRs are created to allow us health check
# port 80 and 8080 separately...
# .. because the BE service can only health check a single port
# We can still chose to use ALL_PORTS instead os hard-coding ports
#---------------------------------

resource "google_compute_forwarding_rule" "fr_orange_80" {
  provider              = google-beta
  name                  = "${var.global.prefix}fr-orange-80"
  region                = "europe-west1"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.be_svc_80.self_link
  subnetwork            = local.untrust.subnet
  ip_address            = "10.0.1.80"
  ip_protocol           = "TCP"
  ports                 = [80]
  service_label         = "orange80"
}

resource "google_compute_forwarding_rule" "fr_orange_8080" {
  provider              = google-beta
  name                  = "${var.global.prefix}fr-orange-8080"
  region                = "europe-west1"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.be_svc_8080.self_link
  subnetwork            = local.untrust.subnet
  ip_address            = "10.0.1.88"
  ip_protocol           = "TCP"
  ports                 = [8080]
  service_label         = "orange8080"
}

# zone1 ILB
#---------------------------------------------

# instance template

resource "google_compute_instance_template" "template" {
  name           = "${var.global.prefix}template"
  region         = "europe-west2"
  machine_type   = "f1-micro"
  can_ip_forward = true
  tags           = ["mig", "gce"]

  disk {
    source_image = "debian-cloud/debian-9"
    boot         = true
  }

  network_interface {
    subnetwork = local.zone1.subnet
    access_config {}
  }

  metadata_startup_script = file("scripts/startup-web.sh")

  service_account {
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_health_check" "zone1_hc_80" {
  name = "${var.global.prefix}zone1-hc-80"

  http_health_check {
    port         = 80
    request_path = "/app80/"
  }
}

resource "google_compute_health_check" "zone1_hc_8080" {
  name = "${var.global.prefix}zone1-hc-8080"

  http_health_check {
    port         = 8080
    request_path = "/app8080/"
  }
}

# managed instance group

resource "google_compute_region_instance_group_manager" "mig" {
  name               = "${var.global.prefix}mig"
  base_instance_name = "${var.global.prefix}mig"
  instance_template  = google_compute_instance_template.template.self_link
  region             = "europe-west2"

  named_port {
    name = "http-80"
    port = "80"
  }

  named_port {
    name = "http-8080"
    port = "8080"
  }
}

# regional autoscalers

resource "google_compute_region_autoscaler" "autoscaler_mig" {
  name   = "${var.global.prefix}autoscaler-mig"
  region = "europe-west2"
  target = google_compute_region_instance_group_manager.mig.self_link

  autoscaling_policy {
    max_replicas    = 3
    min_replicas    = 2
    cooldown_period = 45

    cpu_utilization {
      target = 0.5
    }
  }
}

# internal load balancing - backend services

resource "google_compute_region_backend_service" "zone1_be_svc_80" {
  name     = "${var.global.prefix}zone1-be-svc-80"
  region   = "europe-west2"
  protocol = "TCP"

  backend {
    group = google_compute_region_instance_group_manager.mig.instance_group
  }

  health_checks = [google_compute_health_check.zone1_hc_80.self_link]
}

resource "google_compute_region_backend_service" "zone1_be_svc_8080" {
  name     = "${var.global.prefix}zone1-be-svc-8080"
  region   = "europe-west2"
  protocol = "TCP"

  backend {
    group = google_compute_region_instance_group_manager.mig.instance_group
  }

  health_checks = [google_compute_health_check.zone1_hc_8080.self_link]
}

# Application 80

resource "google_compute_forwarding_rule" "fr_80" {
  name                  = "${var.global.prefix}fr-80"
  region                = "europe-west2"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.zone1_be_svc_80.self_link
  subnetwork            = local.zone1.subnet
  ip_address            = "10.200.20.80"
  ip_protocol           = "TCP"
  ports                 = [80]
}

# Application 8080

resource "google_compute_forwarding_rule" "fr_8080" {
  name                  = "${var.global.prefix}fr-8080"
  region                = "europe-west2"
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.zone1_be_svc_8080.self_link
  subnetwork            = local.zone1.subnet
  ip_address            = "10.200.20.88"
  ip_protocol           = "TCP"
  ports                 = [8080]
}
*/
