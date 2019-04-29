provider "google" {}

provider "google-beta" {}

locals {
  prefix       = ""
  image        = "projects/ubuntu-os-cloud/global/images/ubuntu-1804-bionic-v20190404"
  machine_type = "f1-micro"
}

#============================================
# VPC Demo Configuration
#============================================

# VPC Demo Network
#------------------------------

locals {
  vpc_demo_subnet_10_1_1 = "${local.prefix}vpc-demo-subnet-10-1-1"
  vpc_demo_subnet_10_2_1 = "${local.prefix}vpc-demo-subnet-10-2-1"
  vpc_demo_subnet_10_3_1 = "${local.prefix}vpc-demo-subnet-10-3-1"
}

module "vpc_demo" {
  source  = "terraform-google-modules/network/google"
  version = "0.6.0"

  project_id   = "${var.project_id}"
  network_name = "${local.prefix}vpc-demo"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_demo_subnet_10_1_1}"
      subnet_ip             = "10.1.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = true
      subnet_flow_logs      = true
    },
    {
      subnet_name           = "${local.vpc_demo_subnet_10_2_1}"
      subnet_ip             = "10.2.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = false
      subnet_flow_logs      = true
    },
    {
      subnet_name           = "${local.vpc_demo_subnet_10_3_1}"
      subnet_ip             = "10.3.1.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = true
      subnet_flow_logs      = true
    },
  ]

  secondary_ranges = {
    "${local.vpc_demo_subnet_10_1_1}" = [
      {
        range_name    = "pod-range"
        ip_cidr_range = "10.4.1.0/24"
      },
      {
        range_name    = "svc-range"
        ip_cidr_range = "10.5.1.0/24"
      },
    ]

    "${local.vpc_demo_subnet_10_2_1}" = []
    "${local.vpc_demo_subnet_10_3_1}" = []
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

  source_ranges = ["10.0.0.0/8"]
}

# vm
#-----------------------------------
module "vpc_demo_vm_10_1_1" {
  source                  = "../../modules/gce-private"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo-vm-10-1-1"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_demo.subnets_self_links[0]}"
}

module "vpc_demo_vm_10_2_1" {
  source                  = "../../modules/gce-private"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo-vm-10-2-1"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_demo.subnets_self_links[1]}"
}

module "vpc_demo_vm_10_3_1" {
  source                  = "../../modules/gce-private"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo-vm-10-3-1"
  machine_type            = "${local.machine_type}"
  zone                    = "us-east1-b"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_demo.subnets_self_links[2]}"
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

    # restricted google api range
    advertised_ip_ranges {
      range = "199.36.153.4/30"
    }
  }
}

resource "google_compute_router" "vpc_demo_cr_us_e1" {
  project = "${var.project_id}"
  name    = "${local.prefix}vpc-demo-cr-us-e1"
  network = "${module.vpc_demo.network_self_link}"
  region  = "us-east1"

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

# VPC_demo VPN GW external IP (us-central1)
resource "google_compute_address" "vpc_demo_vpngw_ip_us_e1" {
  project = "${var.project_id}"
  name    = "${local.prefix}vpc-demo-vpngw-ip-us-e1"
  region  = "us-east1"
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

# VPNGW and Tunnel in US Centra1
module "vpc_demo_vpn_us_e1" {
  #source              = "github.com/kaysal/modules.git//gcp/vpn?ref=v1.0"
  source                   = "../../modules/vpn"
  project_id               = "${var.project_id}"
  prefix                   = "${local.prefix}"
  network                  = "${module.vpc_demo.network_self_link}"
  region                   = "us-east1"
  gateway_name             = "vpc-demo-vpngw-us-e1"
  gateway_ip               = "${google_compute_address.vpc_demo_vpngw_ip_us_e1.address}"
  tunnel_name_prefix       = "vpc-demo-us-e1"
  shared_secret            = "${var.psk}"
  tunnel_count             = 1
  cr_name                  = "${google_compute_router.vpc_demo_cr_us_e1.name}"
  peer_asn                 = [64515]
  ike_version              = 2
  peer_ips                 = ["${google_compute_address.vpc_onprem_vpngw_ip_us_c1.address}"]
  bgp_cr_session_range     = ["169.254.100.5/30"]
  bgp_remote_session_range = ["169.254.100.6"]
}

#============================================
# VPC On-prem Configuration
#============================================

locals {
  vpc_onprem_subnet_10_10_10 = "${local.prefix}vpc-onprem-subnet-10-10-10"
}

module "vpc_onprem" {
  source  = "terraform-google-modules/network/google"
  version = "0.6.0"

  project_id   = "${var.project_id}"
  network_name = "${local.prefix}vpc-onprem"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_onprem_subnet_10_10_10}"
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
  ]

  secondary_ranges = {
    "${local.vpc_onprem_subnet_10_10_10}" = []
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

  source_ranges = ["10.0.0.0/8"]
}

# VM Instance
#-----------------------------------
module "vpc_onprem_vm_10_10_10" {
  source                  = "../../modules/gce-private"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-onprem-vm-10-10-10"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_onprem.subnets_self_links[0]}"
  tags                    = []
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
  #source              = "github.com/kaysal/modules.git//gcp/vpn?ref=v1.0"
  source             = "../../modules/vpn"
  project_id         = "${var.project_id}"
  prefix             = "${local.prefix}"
  network            = "${module.vpc_onprem.network_self_link}"
  region             = "us-central1"
  gateway_name       = "vpc-onprem-vpngw-us-c1"
  gateway_ip         = "${google_compute_address.vpc_onprem_vpngw_ip_us_c1.address}"
  tunnel_name_prefix = "vpc-onprem"
  shared_secret      = "${var.psk}"
  tunnel_count       = 2
  cr_name            = "${google_compute_router.vpc_onprem_cr_us_c1.name}"
  peer_asn           = [64514, 64514]
  ike_version        = 2

  peer_ips = [
    "${google_compute_address.vpc_demo_vpngw_ip_us_c1.address}",
    "${google_compute_address.vpc_demo_vpngw_ip_us_e1.address}",
  ]

  bgp_cr_session_range     = ["169.254.100.2/30", "169.254.100.6/30"]
  bgp_remote_session_range = ["169.254.100.1", "169.254.100.5"]
}

#============================================
# GKE Cluster
#============================================

module "gke" {
  source     = "../../modules/gke"
  project_id = "${var.project_id}"

  # cluster
  name                           = "${local.prefix}vpc-demo-cluster"
  enable_private_endpoint        = false
  enable_private_nodes           = true
  master_ipv4_cidr_block         = "172.16.0.0/28"
  min_master_version             = "1.11.8-gke.6"
  network                        = "${module.vpc_demo.network_self_link}"
  subnetwork                     = "${module.vpc_demo.subnets_self_links[0]}"
  min_master_version             = "1.11.8-gke.6"
  pods_range_name                = "pod-range"
  services_range_name            = "svc-range"
  location                       = "europe-west1"
  default_max_pods_per_node      = 16
  remove_default_node_pool       = false
  logging_service                = "logging.googleapis.com/kubernetes"
  monitoring_service             = "monitoring.googleapis.com/kubernetes"
  enable_binary_authorization    = false
  network_policy_enabled         = false
  network_policy_config_disabled = true
  kubernetes_dashboard_disabled  = true
  istio_config_disabled          = true

  cluster_labels = {
    component = "gke"
  }

  # node
  node_count      = 1
  machine_type    = "n1-standard-2"
  service_account = "default"
  network_tags    = []
  node_metadata   = "SECURE"

  node_labels = {
    component = "gke"
  }

  oauth_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
  ]
}
