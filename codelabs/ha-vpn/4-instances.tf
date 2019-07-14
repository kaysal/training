# onprem
#---------------------------------------------

# vm instance

module "vm_onprem" {
  source     = "../modules/gce-private"
  name       = "${local.onprem.prefix}vm"
  zone       = "${local.onprem.region}-b"
  subnetwork = module.vpc_onprem.subnets.*.self_link[0]
}

# hub
#---------------------------------------------

# vm instance

module "vm_hub" {
  source     = "../modules/gce-private"
  name       = "${local.hub.prefix}vm"
  zone       = "${local.hub.region}-b"
  subnetwork = module.vpc_hub.subnets.*.self_link[0]
}
