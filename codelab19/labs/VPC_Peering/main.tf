provider "google" {}

provider "google-beta" {}

locals {
  prefix       = ""
  image        = "debian-cloud/debian-9"
  machine_type = "f1-micro"
}

#============================================
# VPC Demo Configuration
#============================================

# VPC Demo Network
#------------------------------

locals {
  vpc_demo_subnet1 = "${local.prefix}vpc-demo-subnet1"
  vpc_demo_subnet2 = "${local.prefix}vpc-demo-subnet2"
}

module "vpc_demo" {
  source  = "terraform-google-modules/network/google"
  version = "0.6.0"

  project_id   = "${var.project_id}"
  network_name = "${local.prefix}vpc-demo"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_demo_subnet1}"
      subnet_ip             = "10.1.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = true
      subnet_flow_logs      = true
    },
    {
      subnet_name           = "${local.vpc_demo_subnet2}"
      subnet_ip             = "10.2.1.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = true
      subnet_flow_logs      = true
    },
  ]

  secondary_ranges = {
    "${local.vpc_demo_subnet1}" = []
    "${local.vpc_demo_subnet2}" = []
  }
}

# FW Rules
#-----------------------------------
resource "google_compute_firewall" "vpc_demo_ssh" {
  provider    = "google-beta"
  name        = "${local.prefix}vpc-demo-ssh"
  description = "VPC demo SSH FW rule"
  network     = "${module.vpc_demo.network_self_link}"

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpc_demo_icmp" {
  provider    = "google-beta"
  name        = "${local.prefix}vpc-demo-icmp"
  description = "VPC demo ICMP FW rule"
  network     = "${module.vpc_demo.network_self_link}"

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8", "192.168.1.0/24"]
}

# VM Instance
#-----------------------------------
module "vpc_demo_vm1" {
  source                  = "../../modules/gce-public"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo-vm1"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_demo.subnets_self_links[0]}"
}

module "vpc_demo_vm2" {
  source                  = "../../modules/gce-public"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo-vm2"
  machine_type            = "${local.machine_type}"
  zone                    = "us-east1-b"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_demo.subnets_self_links[1]}"
}

# VPC Demo Cloud Routers
#------------------------------
resource "google_compute_router" "vpc_demo_cr_us_c1" {
  project = "${var.project_id}"
  name    = "${local.prefix}vpc-demo-cr-us-c1"
  network = "${module.vpc_demo.network_self_link}"
  region  = "us-central1"

  bgp {
    asn               = 64514
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
  }
}

# VPC Demo VPNs
#-----------------------------------
# VPC_demo VPN GW external IP (us-central1)
resource "google_compute_address" "vpc_demo_vpngw_ip_us_c1" {
  project = "${var.project_id}"
  name    = "${local.prefix}vpc-demo-vpngw-ip-us-c1"
  region  = "us-central1"
}

# VPNGW and Tunnel in US Centra1
module "vpc_demo_vpn_us_c1" {
  source                   = "../../modules/vpn"
  project_id               = "${var.project_id}"
  prefix                   = "${local.prefix}"
  network                  = "${module.vpc_demo.network_self_link}"
  region                   = "us-central1"
  gateway_name             = "vpc-demo-vpngw-us-c1"
  gateway_ip               = "${google_compute_address.vpc_demo_vpngw_ip_us_c1.address}"
  tunnel_name_prefix       = "vpc-demo-us-c1"
  shared_secret            = "${var.psk}"
  tunnel_count             = 1
  cr_name                  = "${google_compute_router.vpc_demo_cr_us_c1.name}"
  peer_asn                 = [64515]
  ike_version              = 2
  peer_ips                 = ["${google_compute_address.vpc_onprem_vpngw_ip_us_c1.address}"]
  bgp_cr_session_range     = ["169.254.100.1/30"]
  bgp_remote_session_range = ["169.254.100.2"]
}

#============================================
# VPC On-prem Configuration
#============================================

locals {
  vpc_onprem_subnet1 = "${local.prefix}vpc-onprem-subnet1"
}

module "vpc_onprem" {
  source       = "terraform-google-modules/network/google"
  version      = "0.6.0"
  project_id   = "${var.project_id}"
  network_name = "${local.prefix}vpc-onprem"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_onprem_subnet1}"
      subnet_ip             = "10.128.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
  ]

  secondary_ranges = {
    "${local.vpc_onprem_subnet1}" = []
  }
}

# FW Rules
#-----------------------------------
resource "google_compute_firewall" "vpc_onprem_ssh" {
  provider    = "google-beta"
  name        = "${local.prefix}vpc-onprem-ssh"
  description = "VPC onprem SSH FW rule"
  network     = "${module.vpc_onprem.network_self_link}"

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpc_onprem_icmp" {
  provider    = "google-beta"
  name        = "${local.prefix}vpc-onprem-icmp"
  description = "VPC onprem ICMP FW rule"
  network     = "${module.vpc_onprem.network_self_link}"

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8", "192.168.1.0/24"]
}

# VM Instance
#-----------------------------------
module "vpc_onprem_vm" {
  source                  = "../../modules/gce-public"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-onprem-vm"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_onprem.subnets_self_links[0]}"
}

# Create vpc-onprem Cloud Router
resource "google_compute_router" "vpc_onprem_cr_us_c1" {
  project = "${var.project_id}"
  name    = "${local.prefix}vpc-onprem-cr-us-c1"
  network = "${module.vpc_onprem.network_self_link}"
  region  = "us-central1"

  bgp {
    asn            = 64515
    advertise_mode = "CUSTOM"

    advertised_ip_ranges {
      range = "${module.vpc_onprem.subnets_ips[0]}"
    }
  }
}

# VPC On-premises VPN
#-----------------------------------
# VPC_onprem VPN GW external IP
resource "google_compute_address" "vpc_onprem_vpngw_ip_us_c1" {
  project = "${var.project_id}"
  name    = "${local.prefix}vpc-onprem-vpngw-ip-us-c1"
  region  = "us-central1"
}

module "vpc_onprem_vpn_us_c1" {
  source                   = "../../modules/vpn"
  project_id               = "${var.project_id}"
  prefix                   = "${local.prefix}"
  network                  = "${module.vpc_onprem.network_self_link}"
  region                   = "us-central1"
  gateway_name             = "vpc-onprem-vpngw-us-c1"
  gateway_ip               = "${google_compute_address.vpc_onprem_vpngw_ip_us_c1.address}"
  tunnel_name_prefix       = "vpc-onprem"
  shared_secret            = "${var.psk}"
  tunnel_count             = 1
  cr_name                  = "${google_compute_router.vpc_onprem_cr_us_c1.name}"
  peer_asn                 = [64514]
  ike_version              = 2
  peer_ips                 = ["${google_compute_address.vpc_demo_vpngw_ip_us_c1.address}"]
  bgp_cr_session_range     = ["169.254.100.2/30"]
  bgp_remote_session_range = ["169.254.100.1"]
}

#============================================
# VPC SaaS Configuration
#============================================

locals {
  vpc_saas_subnet1 = "${local.prefix}vpc-saas-subnet1"
}

module "vpc_saas" {
  source       = "terraform-google-modules/network/google"
  version      = "0.6.0"
  project_id   = "${var.project_id}"
  network_name = "${local.prefix}vpc-saas"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_saas_subnet1}"
      subnet_ip             = "192.168.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
  ]

  secondary_ranges = {
    "${local.vpc_saas_subnet1}" = []
  }
}

# FW Rules
#-----------------------------------
resource "google_compute_firewall" "vpc_saas_ssh" {
  provider    = "google-beta"
  name        = "${local.prefix}vpc-saas-ssh"
  description = "VPC saas SSH FW rule"
  network     = "${module.vpc_saas.network_self_link}"

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "vpc_saas_icmp" {
  provider    = "google-beta"
  name        = "${local.prefix}vpc-saas-icmp"
  description = "VPC saas ICMP FW rule"
  network     = "${module.vpc_saas.network_self_link}"

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/8", "192.168.1.0/24"]
}

# VM Instance
#-----------------------------------
module "vpc_saas_vm" {
  source                  = "../../modules/gce-public"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-saas-vm"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_saas.subnets_self_links[0]}"
}
