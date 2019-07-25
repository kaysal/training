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
    DNS_NAME1            = "vm.onprem.lab"
    DNS_RECORD1          = local.onprem.vm_ip
    DNS_EGRESS_PROXY     = "35.199.192.0/19"
    FORWARD_ZONE1        = "cloud.lab"
    FORWARD_ZONE1_TARGET = "10.10.1.3"
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

# cloud
#---------------------------------------------

# vm instance

module "vm_cloud" {
  source     = "../modules/gce-public"
  name       = "${local.cloud.prefix}vm"
  zone       = "${local.cloud.region}-d"
  subnetwork = module.vpc_cloud.subnets.*.self_link[0]
}

# proxy for forwarding dns queries to on-premises

locals {
  proxy_init = templatefile("${path.module}/scripts/proxy.sh.tpl", {
    DNAT      = "${local.onprem.unbound_ip}"
    SNAT      = "${local.cloud.proxy_ip}"
    NAT_RANGE = "${local.cloud.dns_nat_ip}"
  })
}

module "proxy_cloud" {
  source                  = "../modules/gce-public"
  name                    = "${local.cloud.prefix}proxy"
  zone                    = "${local.cloud.region}-d"
  subnetwork              = module.vpc_cloud.subnets.*.self_link[0]
  network_ip              = local.cloud.proxy_ip
  can_ip_forward          = true
  metadata_startup_script = local.proxy_init
}
