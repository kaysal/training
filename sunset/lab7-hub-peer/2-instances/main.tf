provider "google" {}

provider "google-beta" {}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "iam" {
  backend = "local"

  config = {
    path = "../0-iam/terraform.tfstate"
  }
}

locals {
  instance_init = templatefile("scripts/instance.sh.tpl", {})
  onprem = {
    subnet_a    = data.terraform_remote_state.vpc.outputs.cidrs.onprem_a
    subnet_b    = data.terraform_remote_state.vpc.outputs.cidrs.onprem_b
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.onprem
  }
  hub = {
    subnet_a    = data.terraform_remote_state.vpc.outputs.cidrs.hub_a
    subnet_b    = data.terraform_remote_state.vpc.outputs.cidrs.hub_b
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.hub
  }
  spoke1 = {
    subnet_a    = data.terraform_remote_state.vpc.outputs.cidrs.spoke1_a
    subnet_b    = data.terraform_remote_state.vpc.outputs.cidrs.spoke1_b
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.spoke1
  }
  spoke2 = {
    subnet_a    = data.terraform_remote_state.vpc.outputs.cidrs.spoke2_a
    subnet_b    = data.terraform_remote_state.vpc.outputs.cidrs.spoke2_b
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.spoke2
  }
}

# onprem
#---------------------------------------------

# vm_a instance

resource "google_compute_instance" "onprem_vm_a" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}vm-a"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region_a}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet_a.self_link
    network_ip = var.onprem.vm_a_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# vm_b instance

resource "google_compute_instance" "onprem_vm_b" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}vm-b"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region_b}-c"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet_b.self_link
    network_ip = var.onprem.vm_b_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}


# unbound dns server

locals {
  unbound_init = templatefile("scripts/unbound.sh.tpl", {
    NAME_ONPREM_VM_A   = "vma.onprem.lab"
    RECORD_ONPREM_VM_A = var.onprem.vm_a_ip
    NAME_ONPREM_VM_B   = "vmb.onprem.lab"
    RECORD_ONPREM_VM_B = var.onprem.vm_b_ip
    EGRESS_PROXY       = "35.199.192.0/19"
    NAME_LAB           = "lab."
    FORWARD_LAB_A      = var.hub.dns_inbound_ip_a
    FORWARD_LAB_B      = var.hub.dns_inbound_ip_b
  })
}

resource "google_compute_instance" "onprem_ns" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}ns"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region_a}-b"
  metadata_startup_script   = local.unbound_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet_a.self_link
    network_ip = var.onprem.dns_unbound_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# proxy for forwarding dns queries to hub

locals {
  onprem_proxy_init = templatefile("scripts/proxy.sh.tpl", {
    DNS_PROXY_IP  = "${var.onprem.dns_proxy_ip}"
    REMOTE_DNS_IP = "${var.hub.dns_inbound_ip_a}"
  })
}

resource "google_compute_instance" "onprem_dns_proxy" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}proxy"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region_a}-d"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.onprem_proxy_init

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet_a.self_link
    network_ip = var.onprem.dns_proxy_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# hub
#---------------------------------------------

# proxy for forwarding dns queries to hub

locals {
  hub_proxy_init = templatefile("scripts/proxy.sh.tpl", {
    DNS_PROXY_IP  = "${var.hub.dns_proxy_ip}"
    REMOTE_DNS_IP = "${var.onprem.dns_unbound_ip}"
  })
}

resource "google_compute_instance" "hub_dns_proxy" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}proxy"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.region_a}-d"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.hub_proxy_init

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.subnet_a.self_link
    network_ip = var.hub.dns_proxy_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.hub.svc_account.email
  }
}

# spoke1
#---------------------------------------------

# vm instance

resource "google_compute_instance" "spoke1_vm_a" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}vm-a"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.region_a}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.subnet_a.self_link
    network_ip = var.spoke1.vm_a_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke1.svc_account.email
  }
}

resource "google_compute_instance" "spoke1_vm_b" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}vm-b"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.region_b}-c"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.subnet_b.self_link
    network_ip = var.spoke1.vm_b_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke1.svc_account.email
  }
}

# spoke2
#---------------------------------------------

# vm instance

resource "google_compute_instance" "spoke2_vm_a" {
  project                   = var.project_id_spoke2
  name                      = "${var.spoke2.prefix}vm-a"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.region_a}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.subnet_a.self_link
    network_ip = var.spoke2.vm_a_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke2.svc_account.email
  }
}

resource "google_compute_instance" "spoke2_vm_b" {
  project                   = var.project_id_spoke2
  name                      = "${var.spoke2.prefix}vm-b"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.region_b}-c"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.subnet_b.self_link
    network_ip = var.spoke2.vm_b_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke2.svc_account.email
  }
}
