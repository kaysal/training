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
  vpc_demo_subnet_10_1_1 = "${local.prefix}vpc-demo-subnet-10-1-1"
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
      subnet_name           = "${local.vpc_demo_subnet_10_3_1}"
      subnet_ip             = "10.3.1.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = true
      subnet_flow_logs      = true
    },
  ]

  secondary_ranges = {
    "${local.vpc_demo_subnet_10_1_1}" = []
    "${local.vpc_demo_subnet_10_3_1}" = []
  }
}

resource "google_compute_firewall" "vpc_demo_fw_rules" {
  provider    = "google-beta"
  name        = "${local.prefix}vpc-demo-fw-rules"
  description = "VPC demo FW rules"
  network     = "${module.vpc_demo.network_self_link}"

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}


# VM Instance
#-----------------------------------
module "vpc_demo_vm_10_1_1" {
  source                  = "../../modules/gce"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo-vm-10-1-1"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_demo.subnets_self_links[0]}"
}

module "vpc_demo_vm_10_3_1" {
  source                  = "../../modules/gce"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-demo-vm-10-3-1"
  machine_type            = "${local.machine_type}"
  zone                    = "us-east1-b"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_demo.subnets_self_links[1]}"
}

#============================================
# VPC On-prem Configuration
#============================================

locals {
  vpc_onprem_subnet_10_128_1 = "${local.prefix}vpc-onprem-subnet-10-128-1"
}

module "vpc_onprem" {
  source  = "terraform-google-modules/network/google"
  version = "0.6.0"
  project_id   = "${var.project_id}"
  network_name = "${local.prefix}vpc-onprem"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_onprem_subnet_10_128_1}"
      subnet_ip             = "10.128.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
  ]

  secondary_ranges = {
    "${local.vpc_onprem_subnet_10_128_1}" = []
  }
}

resource "google_compute_firewall" "vpc_onprem_fw_rules" {
  provider    = "google-beta"
  name        = "${local.prefix}vpc-onprem-fw-rules"
  description = "VPC Onprem FW rules"
  network     = "${module.vpc_onprem.network_self_link}"

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

# VM Instance
#-----------------------------------
module "vpc_onprem_vm" {
  source                  = "../../modules/gce"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-onprem-vm"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_onprem.subnets_self_links[0]}"
}

#============================================
# VPC SaaS Configuration
#============================================

locals {
  vpc_saas_subnet_192_168_1 = "${local.prefix}vpc-saas-subnet-192-168-1"
}

module "vpc_saas" {
  source  = "terraform-google-modules/network/google"
  version = "0.6.0"
  project_id   = "${var.project_id}"
  network_name = "${local.prefix}vpc-saas"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_saas_subnet_192_168_1}"
      subnet_ip             = "192.168.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
  ]

  secondary_ranges = {
    "${local.vpc_saas_subnet_192_168_1}" = []
  }
}

resource "google_compute_firewall" "vpc_saas_fw_rules" {
  provider    = "google-beta"
  name        = "${local.prefix}vpc-saas-fw-rules"
  description = "VPC SAAS FW rules"
  network     = "${module.vpc_saas.network_self_link}"

  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["0.0.0.0/0"]
}

# VM Instance
#-----------------------------------
module "vpc_saas_vm" {
  source                  = "../../modules/gce"
  project                 = "${var.project_id}"
  name                    = "${local.prefix}vpc-saas-vm"
  machine_type            = "${local.machine_type}"
  zone                    = "us-central1-a"
  metadata_startup_script = "${file("scripts/startup.sh")}"
  image                   = "${local.image}"
  subnetwork_project      = "${var.project_id}"
  subnetwork              = "${module.vpc_saas.subnets_self_links[0]}"
}
