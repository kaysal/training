provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../vpc/terraform.tfstate"
  }
}

locals {
  onprem = {
    prefix            = "lab2-onprem-"
    region            = "europe-west1"
    vm_ip             = "172.16.1.2"
    dns_proxy_snat_ip = "172.16.1.100"
    dns_proxy_fwd_ip  = "192.168.2.1"
    dns_unbound_ip    = "172.16.1.99"
    subnet_self_link  = data.terraform_remote_state.vpc.outputs.vpc.onprem.subnets.0.self_link
    network_self_link = data.terraform_remote_state.vpc.outputs.vpc.onprem.network.self_link
  }

  cloud = {
    prefix                = "lab2-cloud-"
    region                = "europe-west1"
    vm_ip                 = "10.10.1.2"
    dns_proxy_snat_ip     = "10.10.1.100"
    dns_proxy_fwd_ip      = "192.168.1.1"
    dns_policy_inbound_ip = "10.10.1.3"
    subnet_self_link      = data.terraform_remote_state.vpc.outputs.vpc.cloud.subnets.0.self_link
    network_self_link     = data.terraform_remote_state.vpc.outputs.vpc.cloud.network.self_link
  }
}

# onprem
#---------------------------------------------

# vm instance

locals {
  instance_init = templatefile("${path.module}/scripts/instance.sh.tpl", {})
}

module "onprem_vm" {
  source                  = "../../modules/gce-public"
  name                    = "${local.onprem.prefix}vm"
  zone                    = "${local.onprem.region}-b"
  subnetwork              = local.onprem.subnet_self_link
  network_ip              = local.onprem.vm_ip
  metadata_startup_script = local.instance_init
}

# unbound dns server

locals {
  unbound_init = templatefile("${path.module}/scripts/unbound.sh.tpl", {
    DNS_NAME1            = "vm.onprem.lab"
    DNS_RECORD1          = local.onprem.vm_ip
    DNS_EGRESS_PROXY     = "35.199.192.0/19"
    FORWARD_ZONE1        = "cloud.lab"
    FORWARD_ZONE1_TARGET = local.cloud.dns_proxy_fwd_ip
  })
}

module "onprem_ns" {
  source                  = "../../modules/gce-public"
  name                    = "${local.onprem.prefix}ns"
  zone                    = "${local.onprem.region}-c"
  subnetwork              = local.onprem.subnet_self_link
  network_ip              = local.onprem.dns_unbound_ip
  metadata_startup_script = local.unbound_init
  machine_type            = "n1-standard-1"
}

# proxy for forwarding dns queries to cloud

locals {
  onprem_proxy_init = templatefile("${path.module}/scripts/proxy.sh.tpl", {
    DNAT = "${local.cloud.dns_policy_inbound_ip}"
    SNAT = "${local.onprem.dns_proxy_snat_ip}"
    DEST = "${local.onprem.dns_proxy_fwd_ip}"
  })
}

module "onprem_dns_proxy" {
  source                  = "../../modules/gce-public"
  name                    = "${local.onprem.prefix}proxy"
  zone                    = "${local.onprem.region}-d"
  subnetwork              = local.onprem.subnet_self_link
  network_ip              = local.onprem.dns_proxy_snat_ip
  can_ip_forward          = true
  metadata_startup_script = local.onprem_proxy_init
}

# route pointing to dns nat proxy instance

resource "google_compute_route" "onprem_dns_proxy_route" {
  name        = "${local.onprem.prefix}dns-proxy-route"
  dest_range  = "${local.onprem.dns_proxy_fwd_ip}/32"
  network     = local.onprem.network_self_link
  next_hop_ip = module.onprem_dns_proxy.instance.network_interface.0.network_ip
  priority    = 100
}

# cloud
#---------------------------------------------

# vm instance

module "cloud_vm" {
  source     = "../../modules/gce-public"
  name       = "${local.cloud.prefix}vm"
  zone       = "${local.cloud.region}-d"
  subnetwork = local.cloud.subnet_self_link
  network_ip = local.cloud.vm_ip
}

# proxy for forwarding dns queries to on-premises

locals {
  cloud_proxy_init = templatefile("${path.module}/scripts/proxy.sh.tpl", {
    DNAT = "${local.onprem.dns_unbound_ip}"
    SNAT = "${local.cloud.dns_proxy_snat_ip}"
    DEST = "${local.cloud.dns_proxy_fwd_ip}"
  })
}

module "cloud_dns_proxy" {
  source                  = "../../modules/gce-public"
  name                    = "${local.cloud.prefix}proxy"
  zone                    = "${local.cloud.region}-d"
  subnetwork              = local.cloud.subnet_self_link
  network_ip              = local.cloud.dns_proxy_snat_ip
  can_ip_forward          = true
  metadata_startup_script = local.cloud_proxy_init
}

# route pointing to dns nat proxy instance

resource "google_compute_route" "cloud_dns_proxy_route" {
  name        = "${local.cloud.prefix}dns-proxy-route"
  dest_range  = "${local.cloud.dns_proxy_fwd_ip}/32"
  network     = local.cloud.network_self_link
  next_hop_ip = module.cloud_dns_proxy.instance.network_interface.0.network_ip
  priority    = 100
}
