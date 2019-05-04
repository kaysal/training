provider "google" {}

provider "google-beta" {}

locals {
  prefix       = ""
}

#============================================
# VPC Demo Configuration
#============================================

# VPC Demo Network
#------------------------------

locals {
  vpc_demo_subnet1 = "${local.prefix}vpc-demo-subnet1"
  vpc_demo_subnet2 = "${local.prefix}vpc-demo-subnet2"
  vpc_demo_subnet3 = "${local.prefix}vpc-demo-subnet3"
}

# VPC and Subnets

module "vpc_demo" {
  source  = "terraform-google-modules/network/google"
  version = "0.6.0"

  project_id   = "${var.project_id}"
  network_name = "${local.prefix}vpc-demo"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_demo_subnet1}"
      subnet_ip             = "10.1.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "${local.vpc_demo_subnet2}"
      subnet_ip             = "10.2.1.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
    {
      subnet_name           = "${local.vpc_demo_subnet3}"
      subnet_ip             = "10.3.1.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
  ]

  secondary_ranges = {
    "${local.vpc_demo_subnet1}" = []
    "${local.vpc_demo_subnet2}" = []
    "${local.vpc_demo_subnet3}" = []
  }
}

# FW rule for health check

resource "google_compute_firewall" "vpc_demo_allow_health_checks" {
  provider = "google-beta"
  name     = "${local.prefix}vpc-demo-allow-health-checks"
  network  = "${module.vpc_demo.network_self_link}"

  allow {
    protocol = "tcp"
    ports    = [80, 8000]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
}

# FW rule for HTTP from RFC1918

resource "google_compute_firewall" "vpc_demo_allow_http_rfc1918" {
  provider = "google-beta"
  name     = "${local.prefix}vpc-demo-allow-http-rfc1918"
  network  = "${module.vpc_demo.network_self_link}"

  allow {
    protocol = "tcp"
    ports    = [80, 8000]
  }

  source_ranges = [
    "10.0.0.0/8",
    "192.168.0.0/16"
  ]
}
