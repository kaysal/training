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
    belgium_subnet = data.terraform_remote_state.vpc.outputs.vpc.onprem.belgium_subnet
    london_subnet  = data.terraform_remote_state.vpc.outputs.vpc.onprem.london_subnet
    svc_account    = data.terraform_remote_state.iam.outputs.iam.onprem.svc_account
  }
  hub = {
    belgium_subnet = data.terraform_remote_state.vpc.outputs.vpc.hub.belgium_subnet
    london_subnet  = data.terraform_remote_state.vpc.outputs.vpc.hub.london_subnet
    svc_account    = data.terraform_remote_state.iam.outputs.iam.hub.svc_account
  }
  spoke1 = {
    belgium_subnet = data.terraform_remote_state.vpc.outputs.vpc.spoke1.belgium_subnet
    london_subnet  = data.terraform_remote_state.vpc.outputs.vpc.spoke1.london_subnet
    svc_account    = data.terraform_remote_state.iam.outputs.iam.spoke1.svc_account
  }
  spoke2 = {
    belgium_subnet = data.terraform_remote_state.vpc.outputs.vpc.spoke2.belgium_subnet
    london_subnet  = data.terraform_remote_state.vpc.outputs.vpc.spoke2.london_subnet
    svc_account    = data.terraform_remote_state.iam.outputs.iam.spoke2.svc_account
  }
}

# onprem
#---------------------------------------------

# belgium instance

resource "google_compute_instance" "onprem_belgium_vm" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}belgium-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.belgium.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.belgium_subnet.self_link
    network_ip = var.onprem.belgium.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.onprem.svc_account.email
  }
}

# london instance

resource "google_compute_instance" "onprem_london_vm" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}london-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.london.region}-c"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.london_subnet.self_link
    network_ip = var.onprem.london.vm_ip
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
    name1        = "vm.belgium.onprem.lab"
    record1      = var.onprem.belgium.vm_ip
    name2        = "vm.london.onprem.lab"
    record2      = var.onprem.london.vm_ip
    name_lab     = "lab."
    egress_proxy = "35.199.192.0/19"
  })
}

resource "google_compute_instance" "onprem_belgium_ns" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}belgium-ns"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.belgium.region}-b"
  metadata_startup_script   = local.unbound_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.belgium_subnet.self_link
    network_ip = var.onprem.ns_ip
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
    proxy_ip     = "${var.onprem.proxy_ip}"
    remote_ns_ip = "${var.hub.dns_inbound_ip_a}"
  })
}

resource "google_compute_instance" "onprem_belgium_proxy" {
  project                   = var.project_id_onprem
  name                      = "${var.onprem.prefix}belgium-proxy"
  machine_type              = var.global.machine_type
  zone                      = "${var.onprem.belgium.region}-d"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.onprem_proxy_init

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.onprem.belgium_subnet.self_link
    network_ip = var.onprem.proxy_ip
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
    proxy_ip     = "${var.hub.proxy_ip}"
    remote_ns_ip = "${var.onprem.ns_ip}"
  })
}

resource "google_compute_instance" "hub_belgium_proxy" {
  project                   = var.project_id_hub
  name                      = "${var.hub.prefix}belgium-proxy"
  machine_type              = var.global.machine_type
  zone                      = "${var.hub.belgium.region}-d"
  can_ip_forward            = true
  allow_stopping_for_update = true
  metadata_startup_script   = local.hub_proxy_init

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.hub.belgium_subnet.self_link
    network_ip = var.hub.proxy_ip
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

resource "google_compute_instance" "spoke1_belgium_vm" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}belgium-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.belgium.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.belgium_subnet.self_link
    network_ip = var.spoke1.belgium.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke1.svc_account.email
  }
}

resource "google_compute_instance" "spoke1_london_vm" {
  project                   = var.project_id_spoke1
  name                      = "${var.spoke1.prefix}london-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke1.london.region}-c"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke1.london_subnet.self_link
    network_ip = var.spoke1.london.vm_ip
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

resource "google_compute_instance" "spoke2_belgium_vm" {
  project                   = var.project_id_spoke2
  name                      = "${var.spoke2.prefix}belgium-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.belgium.region}-b"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.belgium_subnet.self_link
    network_ip = var.spoke2.belgium.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke2.svc_account.email
  }
}

resource "google_compute_instance" "spoke2_london_vm" {
  project                   = var.project_id_spoke2
  name                      = "${var.spoke2.prefix}london-vm"
  machine_type              = var.global.machine_type
  zone                      = "${var.spoke2.london.region}-c"
  metadata_startup_script   = local.instance_init
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.global.image.debian
    }
  }

  network_interface {
    subnetwork = local.spoke2.london_subnet.self_link
    network_ip = var.spoke2.london.vm_ip
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
    email  = local.spoke2.svc_account.email
  }
}
