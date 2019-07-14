provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# local variables

locals {
  # onprem
  onprem_prefix  = "onprem-"
  onprem_region  = "europe-west2"
  onprem_asn     = "65001"
  onprem_cr_vti1 = "169.254.100.1"
  onprem_cr_vti2 = "169.254.100.5"
  onprem_subnet  = "onprem-subnet"

  # hub
  hub_prefix  = "hub-"
  hub_region  = "europe-west2"
  hub_asn     = "65002"
  hub_cr_vti1 = "169.254.100.2"
  hub_cr_vti2 = "169.254.100.6"
  hub_subnet  = "hub-subnet"
}

# onprem configuration
#---------------------------------------------

# vpc

module "vpc_onprem" {
  source       = "../modules/vpc"
  project_id   = var.project_id
  network_name = "${local.onprem_prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "${local.onprem_prefix}subnet"
      subnet_ip     = "172.16.1.0/24"
      subnet_region = local.onprem_region
    },
  ]

  secondary_ranges = {
    "${local.onprem_subnet}" = []
  }
}

# firewall rules

resource "google_compute_firewall" "onprem_allow_ssh" {
  name    = "${local.onprem_prefix}allow-ssh"
  network = module.vpc_onprem.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "onprem_allow_icmp" {
  name    = "${local.onprem_prefix}allow-icmp"
  network = module.vpc_onprem.network_self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8", "172.0.0.0/8", ]
}

# cloud router

resource "google_compute_router" "onprem_cr" {
  name    = "${local.onprem_prefix}cr"
  network = module.vpc_onprem.network_self_link
  region  = local.onprem_region

  bgp {
    asn               = local.onprem_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# vpn gateway

resource "google_compute_ha_vpn_gateway" "onprem_vpn_gw" {
  provider = "google-beta"
  region   = local.onprem_region
  name     = "${local.onprem_prefix}vpn-gw"
  network  = module.vpc_onprem.network_self_link
}

# vpn tunnel

module "vpn_onprem_to_hub" {
  source           = "../modules/vpn-ha-gcp"
  project_id       = var.project_id
  network          = module.vpc_onprem.network_self_link
  region           = local.onprem_region
  vpn_gateway      = google_compute_ha_vpn_gateway.onprem_vpn_gw.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.hub_vpn_gw.self_link
  shared_secret    = var.psk
  router           = google_compute_router.onprem_cr.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${local.onprem_prefix}to-hub"
      peer_asn                  = local.hub_asn
      cr_bgp_session_range      = "${local.onprem_cr_vti1}/30"
      remote_bgp_session_ip     = local.hub_cr_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${local.onprem_prefix}to-hub"
      peer_asn                  = local.hub_asn
      cr_bgp_session_range      = "${local.onprem_cr_vti2}/30"
      remote_bgp_session_ip     = local.hub_cr_vti2
      advertised_route_priority = 100
    },
  ]
}


# hub configuration
#---------------------------------------------

# vpc

module "vpc_hub" {
  source       = "../modules/vpc"
  project_id   = var.project_id
  network_name = "${local.hub_prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name   = "${local.hub_prefix}subnet"
      subnet_ip     = "10.10.0.0/24"
      subnet_region = local.hub_region
    },
  ]

  secondary_ranges = {
    "${local.hub_subnet}" = []
  }
}

# firewall rules

resource "google_compute_firewall" "hub_allow_ssh" {
  name    = "${local.hub_prefix}allow-ssh"
  network = module.vpc_hub.network_self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "hub_allow_icmp" {
  name    = "${local.hub_prefix}allow-icmp"
  network = module.vpc_hub.network_self_link

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8", "172.0.0.0/8", ]
}

# cloud router

resource "google_compute_router" "hub_cr" {
  name    = "${local.hub_prefix}cr"
  network = module.vpc_hub.network_self_link
  region  = local.hub_region

  bgp {
    asn               = local.hub_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# vpn gateway

resource "google_compute_ha_vpn_gateway" "hub_vpn_gw" {
  provider = "google-beta"
  region   = local.hub_region
  name     = "${local.hub_prefix}vpn-gw"
  network  = module.vpc_hub.network_self_link
}

# vpn tunnel

module "vpn_hub_to_onprem" {
  source           = "../modules/vpn-ha-gcp"
  project_id       = var.project_id
  network          = module.vpc_hub.network_self_link
  region           = local.hub_region
  vpn_gateway      = google_compute_ha_vpn_gateway.hub_vpn_gw.self_link
  peer_gcp_gateway = google_compute_ha_vpn_gateway.onprem_vpn_gw.self_link
  shared_secret    = var.psk
  router           = google_compute_router.hub_cr.name
  ike_version      = 2

  session_config = [
    {
      session_name              = "${local.hub_prefix}to-onprem"
      peer_asn                  = local.onprem_asn
      cr_bgp_session_range      = "${local.hub_cr_vti1}/30"
      remote_bgp_session_ip     = local.onprem_cr_vti1
      advertised_route_priority = 100
    },
    {
      session_name              = "${local.hub_prefix}to-onprem"
      peer_asn                  = local.onprem_asn
      cr_bgp_session_range      = "${local.hub_cr_vti2}/30"
      remote_bgp_session_ip     = local.onprem_cr_vti2
      advertised_route_priority = 100
    },
  ]
}
