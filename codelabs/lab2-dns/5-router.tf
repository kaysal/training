
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

# cloud
#---------------------------------------------

# cloud router

resource "google_compute_router" "cloud_router" {
  name    = "${local.cloud.prefix}router"
  network = module.vpc_cloud.network.self_link
  region  = local.cloud.region

  bgp {
    asn               = local.cloud.asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}
