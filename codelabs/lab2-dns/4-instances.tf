# onprem
#---------------------------------------------

# vm instance

locals {
  instance_init = templatefile("${path.module}/scripts/instance.sh.tpl", {})
}

module "vm_onprem" {
  source                  = "../modules/gce-public"
  name                    = "${local.onprem.prefix}vm"
  zone                    = "${local.onprem.region}-b"
  subnetwork              = module.vpc_onprem.subnets.*.self_link[0]
  network_ip              = local.onprem.vm_ip
  metadata_startup_script = local.instance_init
}

# unbound dns server

locals {
  unbound_init = templatefile("${path.module}/scripts/unbound.sh.tpl", {
    LOCAL_DATA1 = "local-data: 'vm.onprem.lab A ${local.onprem.vm_ip}'"
    DNS_EGRESS_PROXY = "35.199.192.0/19"
  })
}

module "ns_onprem" {
  source                  = "../modules/gce-public"
  name                    = "${local.onprem.prefix}ns"
  zone                    = "${local.onprem.region}-c"
  subnetwork              = module.vpc_onprem.subnets.*.self_link[0]
  network_ip              = local.onprem.unbound_ip
  metadata_startup_script = local.unbound_init
}

# hub
#---------------------------------------------

# vm instance

module "vm_hub" {
  source     = "../modules/gce-public"
  name       = "${local.hub.prefix}vm"
  zone       = "${local.hub.region}-d"
  subnetwork = module.vpc_hub.subnets.*.self_link[0]
}
