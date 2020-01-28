provider "google" {}

provider "google-beta" {}

provider "random" {}

# remote state

data "terraform_remote_state" "vpc" {
  backend = "local"

  config = {
    path = "../1-vpc/terraform.tfstate"
  }
}

data "terraform_remote_state" "router" {
  backend = "local"

  config = {
    path = "../3-router/terraform.tfstate"
  }
}

data "terraform_remote_state" "gateway" {
  backend = "local"

  config = {
    path = "../4-vpn-gw/terraform.tfstate"
  }
}

locals {
  onprem = {
    vpc         = data.terraform_remote_state.vpc.outputs.networks.onprem
    eu_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.onprem.eu_cidr
    asia_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.onprem.asia_cidr
    us_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.onprem.us_cidr
    vpn_eu      = data.terraform_remote_state.gateway.outputs.gateway.onprem.vpn_eu
    vpn_asia    = data.terraform_remote_state.gateway.outputs.gateway.onprem.vpn_asia
    vpn_us      = data.terraform_remote_state.gateway.outputs.gateway.onprem.vpn_us
    vpn_eu_ip   = data.terraform_remote_state.gateway.outputs.gateway.onprem.vpn_eu_ip
    vpn_asia_ip = data.terraform_remote_state.gateway.outputs.gateway.onprem.vpn_asia_ip
    vpn_us_ip   = data.terraform_remote_state.gateway.outputs.gateway.onprem.vpn_us_ip
    router_eu   = data.terraform_remote_state.router.outputs.routers.onprem.eu
    router_asia = data.terraform_remote_state.router.outputs.routers.onprem.asia
    router_us   = data.terraform_remote_state.router.outputs.routers.onprem.us
  }
  hub = {
    vpc_eu1      = data.terraform_remote_state.vpc.outputs.networks.hub.eu1
    vpc_eu1x     = data.terraform_remote_state.vpc.outputs.networks.hub.eu1x
    vpc_eu2      = data.terraform_remote_state.vpc.outputs.networks.hub.eu2
    vpc_eu2x     = data.terraform_remote_state.vpc.outputs.networks.hub.eu2x
    vpc_asia1    = data.terraform_remote_state.vpc.outputs.networks.hub.asia1
    vpc_asia1x   = data.terraform_remote_state.vpc.outputs.networks.hub.asia1x
    vpc_asia2    = data.terraform_remote_state.vpc.outputs.networks.hub.asia2
    vpc_asia2x   = data.terraform_remote_state.vpc.outputs.networks.hub.asia2x
    vpc_us1      = data.terraform_remote_state.vpc.outputs.networks.hub.us1
    vpc_us1x     = data.terraform_remote_state.vpc.outputs.networks.hub.us1x
    vpc_us2      = data.terraform_remote_state.vpc.outputs.networks.hub.us2
    vpc_us2x     = data.terraform_remote_state.vpc.outputs.networks.hub.us2x
    eu1_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu1_cidr
    eu1_cidrx    = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu1_cidrx
    eu2_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu2_cidr
    eu2_cidrx    = data.terraform_remote_state.vpc.outputs.cidrs.hub.eu2_cidrx
    asia1_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia1_cidr
    asia1_cidrx  = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia1_cidrx
    asia2_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia2_cidr
    asia2_cidrx  = data.terraform_remote_state.vpc.outputs.cidrs.hub.asia2_cidrx
    us1_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.hub.us1_cidr
    us1_cidrx    = data.terraform_remote_state.vpc.outputs.cidrs.hub.us1_cidrx
    us2_cidr     = data.terraform_remote_state.vpc.outputs.cidrs.hub.us2_cidr
    us2_cidrx    = data.terraform_remote_state.vpc.outputs.cidrs.hub.us2_cidrx
    vpn_eu1      = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_eu1
    vpn_eu2      = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_eu2
    vpn_asia1    = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_asia1
    vpn_asia2    = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_asia2
    vpn_us1      = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_us1
    vpn_us2      = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_us2
    vpn_eu1_ip   = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_eu1_ip
    vpn_eu2_ip   = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_eu2_ip
    vpn_asia1_ip = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_asia1_ip
    vpn_asia2_ip = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_asia2_ip
    vpn_us1_ip   = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_us1_ip
    vpn_us2_ip   = data.terraform_remote_state.gateway.outputs.gateway.hub.vpn_us2_ip
    router_eu1   = data.terraform_remote_state.router.outputs.routers.hub.eu1
    router_eu2   = data.terraform_remote_state.router.outputs.routers.hub.eu2
    router_asia1 = data.terraform_remote_state.router.outputs.routers.hub.asia1
    router_asia2 = data.terraform_remote_state.router.outputs.routers.hub.asia2
    router_us1   = data.terraform_remote_state.router.outputs.routers.hub.us1
    router_us2   = data.terraform_remote_state.router.outputs.routers.hub.us2
  }
  svc = {
    vpc_svc    = data.terraform_remote_state.vpc.outputs.networks.svc
    eu1_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.svc.eu1_cidr
    eu2_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.svc.eu2_cidr
    asia1_cidr = data.terraform_remote_state.vpc.outputs.cidrs.svc.asia1_cidr
    asia2_cidr = data.terraform_remote_state.vpc.outputs.cidrs.svc.asia2_cidr
    us1_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.svc.us1_cidr
    us2_cidr   = data.terraform_remote_state.vpc.outputs.cidrs.svc.us2_cidr
  }
}

resource "random_id" "ipsec_secret" {
  byte_length = 8
}

# onprem
#---------------------------------------------

# tunnel to hub eu1

module "vpn_onprem_to_hub_eu1" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_onprem
  network                   = local.onprem.vpc.self_link
  region                    = var.onprem.eu.region
  gateway                   = local.onprem.vpn_eu.self_link
  tunnel_name               = "${var.onprem.prefix}to-hub-eu1"
  shared_secret             = random_id.ipsec_secret.b64_url
  peer_ip                   = local.hub.vpn_eu1_ip.address
  cr_name                   = local.onprem.router_eu.name
  bgp_cr_session_range      = "${var.onprem.eu.cr_vti1}/30"
  bgp_remote_session_range  = var.hub.eu1.cr_vti
  peer_asn                  = var.hub.asn
  advertised_route_priority = 100
}

# tunnel to hub eu2

module "vpn_onprem_to_hub_eu2" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_onprem
  network                   = local.onprem.vpc.self_link
  region                    = var.onprem.eu.region
  gateway                   = local.onprem.vpn_eu.self_link
  tunnel_name               = "${var.onprem.prefix}to-hub-eu2"
  shared_secret             = random_id.ipsec_secret.b64_url
  peer_ip                   = local.hub.vpn_eu2_ip.address
  cr_name                   = local.onprem.router_eu.name
  bgp_cr_session_range      = "${var.onprem.eu.cr_vti2}/30"
  bgp_remote_session_range  = var.hub.eu2.cr_vti
  peer_asn                  = var.hub.asn
  advertised_route_priority = 100
}

# tunnel to hub asia1

module "vpn_onprem_to_hub_asia1" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_onprem
  network                   = local.onprem.vpc.self_link
  region                    = var.onprem.asia.region
  gateway                   = local.onprem.vpn_asia.self_link
  tunnel_name               = "${var.onprem.prefix}to-hub-asia1"
  shared_secret             = random_id.ipsec_secret.b64_url
  cr_name                   = local.onprem.router_asia.name
  bgp_cr_session_range      = "${var.onprem.asia.cr_vti1}/30"
  bgp_remote_session_range  = var.hub.asia1.cr_vti
  peer_ip                   = local.hub.vpn_asia1_ip.address
  peer_asn                  = var.hub.asn
  advertised_route_priority = 100
}

# tunnel to hub asia2

module "vpn_onprem_to_hub_asia2" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_onprem
  network                   = local.onprem.vpc.self_link
  region                    = var.onprem.asia.region
  gateway                   = local.onprem.vpn_asia.self_link
  tunnel_name               = "${var.onprem.prefix}to-hub-asia2"
  shared_secret             = random_id.ipsec_secret.b64_url
  cr_name                   = local.onprem.router_asia.name
  bgp_cr_session_range      = "${var.onprem.asia.cr_vti2}/30"
  bgp_remote_session_range  = var.hub.asia2.cr_vti
  peer_ip                   = local.hub.vpn_asia2_ip.address
  peer_asn                  = var.hub.asn
  advertised_route_priority = 100
}

# tunnel to hub us1

module "vpn_onprem_to_hub_us1" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_onprem
  network                   = local.onprem.vpc.self_link
  region                    = var.onprem.us.region
  gateway                   = local.onprem.vpn_us.self_link
  tunnel_name               = "${var.onprem.prefix}to-hub-us1"
  shared_secret             = random_id.ipsec_secret.b64_url
  cr_name                   = local.onprem.router_us.name
  bgp_cr_session_range      = "${var.onprem.us.cr_vti1}/30"
  bgp_remote_session_range  = var.hub.us1.cr_vti
  peer_ip                   = local.hub.vpn_us1_ip.address
  peer_asn                  = var.hub.asn
  advertised_route_priority = 100
}

# tunnel to hub us2

module "vpn_onprem_to_hub_us2" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_onprem
  network                   = local.onprem.vpc.self_link
  region                    = var.onprem.us.region
  gateway                   = local.onprem.vpn_us.self_link
  tunnel_name               = "${var.onprem.prefix}to-hub-us2"
  shared_secret             = random_id.ipsec_secret.b64_url
  cr_name                   = local.onprem.router_us.name
  bgp_cr_session_range      = "${var.onprem.us.cr_vti2}/30"
  bgp_remote_session_range  = var.hub.us2.cr_vti
  peer_ip                   = local.hub.vpn_us2_ip.address
  peer_asn                  = var.hub.asn
  advertised_route_priority = 100
}

# hub
#---------------------------------------------

# tunnel hub eu1 to onprem eu

module "vpn_hub_eu1_to_onprem_eu" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_hub
  network                   = local.hub.vpc_eu1.self_link
  region                    = var.hub.eu1.region
  gateway                   = local.hub.vpn_eu1.self_link
  tunnel_name               = "${var.hub.prefix}to-onprem-eu-1"
  shared_secret             = random_id.ipsec_secret.b64_url
  cr_name                   = local.hub.router_eu1.name
  bgp_cr_session_range      = "${var.hub.eu1.cr_vti}/30"
  bgp_remote_session_range  = var.onprem.eu.cr_vti1
  peer_ip                   = local.onprem.vpn_eu_ip.address
  peer_asn                  = var.onprem.asn
  advertised_route_priority = 100
}

# tunnel hub eu2 to onprem eu

module "vpn_hub_eu2_to_onprem_eu" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_hub
  network                   = local.hub.vpc_eu2.self_link
  region                    = var.hub.eu2.region
  gateway                   = local.hub.vpn_eu2.self_link
  tunnel_name               = "${var.hub.prefix}to-onprem-eu-2"
  shared_secret             = random_id.ipsec_secret.b64_url
  cr_name                   = local.hub.router_eu2.name
  bgp_cr_session_range      = "${var.hub.eu2.cr_vti}/30"
  bgp_remote_session_range  = var.onprem.eu.cr_vti2
  peer_ip                   = local.onprem.vpn_eu_ip.address
  peer_asn                  = var.onprem.asn
  advertised_route_priority = 100
}

# tunnel hub asia1 to onprem asia

module "vpn_hub_asia1_to_onprem_asia" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_hub
  network                   = local.hub.vpc_asia1.self_link
  region                    = var.hub.asia1.region
  gateway                   = local.hub.vpn_asia1.self_link
  tunnel_name               = "${var.hub.prefix}to-onprem-asia-1"
  shared_secret             = random_id.ipsec_secret.b64_url
  cr_name                   = local.hub.router_asia1.name
  bgp_cr_session_range      = "${var.hub.asia1.cr_vti}/30"
  bgp_remote_session_range  = var.onprem.asia.cr_vti1
  peer_ip                   = local.onprem.vpn_asia_ip.address
  peer_asn                  = var.onprem.asn
  advertised_route_priority = 100
}

# tunnel hub asia2 to onprem asia

module "vpn_hub_asia2_to_onprem_asia" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_hub
  network                   = local.hub.vpc_asia2.self_link
  region                    = var.hub.asia2.region
  gateway                   = local.hub.vpn_asia2.self_link
  tunnel_name               = "${var.hub.prefix}to-onprem-asia-2"
  shared_secret             = random_id.ipsec_secret.b64_url
  cr_name                   = local.hub.router_asia2.name
  bgp_cr_session_range      = "${var.hub.asia2.cr_vti}/30"
  bgp_remote_session_range  = var.onprem.asia.cr_vti2
  peer_ip                   = local.onprem.vpn_asia_ip.address
  peer_asn                  = var.onprem.asn
  advertised_route_priority = 100
}

# tunnel hub us1 to onprem us

module "vpn_hub_us1_to_onprem_us" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_hub
  network                   = local.hub.vpc_us1.self_link
  region                    = var.hub.us1.region
  gateway                   = local.hub.vpn_us1.self_link
  tunnel_name               = "${var.hub.prefix}to-onprem-us-1"
  shared_secret             = random_id.ipsec_secret.b64_url
  cr_name                   = local.hub.router_us1.name
  bgp_cr_session_range      = "${var.hub.us1.cr_vti}/30"
  bgp_remote_session_range  = var.onprem.us.cr_vti1
  peer_ip                   = local.onprem.vpn_us_ip.address
  peer_asn                  = var.onprem.asn
  advertised_route_priority = 100
}

# tunnel hub us2 to onprem us

module "vpn_hub_us2_to_onprem_us" {
  source                    = "../../modules/vpn"
  project_id                = var.project_id_hub
  network                   = local.hub.vpc_us2.self_link
  region                    = var.hub.us2.region
  gateway                   = local.hub.vpn_us2.self_link
  tunnel_name               = "${var.hub.prefix}to-onprem-us-2"
  shared_secret             = random_id.ipsec_secret.b64_url
  cr_name                   = local.hub.router_us2.name
  bgp_cr_session_range      = "${var.hub.us2.cr_vti}/30"
  bgp_remote_session_range  = var.onprem.us.cr_vti2
  peer_ip                   = local.onprem.vpn_us_ip.address
  peer_asn                  = var.onprem.asn
  advertised_route_priority = 100
}
