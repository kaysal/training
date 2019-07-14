
# onprem
#---------------------------------------------

# cloud router

resource "google_compute_router" "onprem_router" {
  name    = "${local.onprem.prefix}router"
  network = module.vpc_onprem.network.self_link
  region  = local.onprem.region

  bgp {
    asn               = local.onprem.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# hub
#---------------------------------------------

# cloud router

resource "google_compute_router" "hub_router" {
  name    = "${local.hub.prefix}router"
  network = module.vpc_hub.network.self_link
  region  = local.hub.region

  bgp {
    asn               = local.hub.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}
