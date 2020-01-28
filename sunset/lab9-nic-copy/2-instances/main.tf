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
    subnet1     = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet1
    subnet2     = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet2
    subnet3     = data.terraform_remote_state.vpc.outputs.cidrs.onprem.subnet3
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.onprem
  }
  hub = {
    subnet1     = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet1
    subnet2     = data.terraform_remote_state.vpc.outputs.cidrs.hub.subnet2
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.hub
  }
  spoke1 = {
    subnet1     = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet1
    subnet2     = data.terraform_remote_state.vpc.outputs.cidrs.spoke1.subnet2
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.spoke1
  }
  spoke2 = {
    subnet1     = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet1
    subnet2     = data.terraform_remote_state.vpc.outputs.cidrs.spoke2.subnet2
    svc_account = data.terraform_remote_state.iam.outputs.svc_account.spoke2
  }
}

# onprem
#---------------------------------------------

# vm1 instance

resource "google_compute_instance" "onprem_vm1" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}vm1"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true
  tags                      = ["${var.onprem.prefix}vm1"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet1.self_link
    network_ip = var.onprem.vm1_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# vm2 instance

resource "google_compute_instance" "onprem_vm2" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}vm2"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region}-c"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true
  tags                      = ["${var.onprem.prefix}vm2"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet2.self_link
    network_ip = var.onprem.vm2_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}


# unbound dns instance

locals {
  unbound_init = templatefile("scripts/unbound.sh.tpl", {
    NAME_ONPREM_VM1   = "vm1.onprem.lab"
    NAME_ONPREM_VM2   = "vm2.onprem.lab"
    NAME_ONPREM_VM3   = "vm3.onprem.lab"
    RECORD_ONPREM_VM1 = var.onprem.vm1_ip
    RECORD_ONPREM_VM2 = var.onprem.vm2_ip
    RECORD_ONPREM_VM3 = var.onprem.dns_unbound_ip
    EGRESS_PROXY      = "35.199.192.0/19"
    NAME_LAB          = "lab."
    FORWARD_LAB_A     = var.hub.dns_inbound_ip_a
    FORWARD_LAB_B     = var.hub.dns_inbound_ip_b
  })
}

resource "google_compute_instance" "onprem_ns" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}ns"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.region}-b"
  metadata_startup_script   = local.unbound_init
  allow_stopping_for_update = true
  tags                      = ["${var.onprem.prefix}ns"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet3.self_link
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
  zone                      = "${var.onprem.region}-c"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.onprem_proxy_init
  tags                      = ["${var.onprem.prefix}proxy"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.subnet3.self_link
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
  zone                      = "${var.hub.region_b}-b"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.hub_proxy_init
  tags                      = ["${var.hub.prefix}proxy"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.subnet2.self_link
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

# vm instances

resource "google_compute_instance" "spoke1_vm1" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}vm1"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true
  tags                      = ["${var.spoke1.prefix}vm1"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.subnet1.self_link
    network_ip = var.spoke1.vm1_ip
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke1.svc_account.email
  }
}

resource "google_compute_instance" "spoke1_vm2" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}vm2"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true
  tags                      = ["${var.spoke1.prefix}vm2"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.subnet2.self_link
    network_ip = var.spoke1.vm2_ip
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke1.svc_account.email
  }
}

# spoke2
#---------------------------------------------

# vm instances

resource "google_compute_instance" "spoke2_vm1" {
  project                   = var.project_id_spoke2
  name                      = "${var.spoke2.prefix}vm1"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true
  tags                      = ["${var.spoke2.prefix}vm1"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.subnet1.self_link
    network_ip = var.spoke2.vm1_ip
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke2.svc_account.email
  }
}

resource "google_compute_instance" "spoke2_vm2" {
  project                   = var.project_id_spoke2
  name                      = "${var.spoke2.prefix}vm2"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true
  tags                      = ["${var.spoke2.prefix}vm2"]

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.subnet2.self_link
    network_ip = var.spoke2.vm2_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke2.svc_account.email
  }
}
