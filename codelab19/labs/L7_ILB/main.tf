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

locals {
  vpc_demo_subnet_l7_ilb = "${local.prefix}vpc-demo-subnet-l7-ilb"
}

module "vpc_demo" {
  source  = "terraform-google-modules/network/google"
  version = "0.6.0"

  project_id   = "${var.project_id}"
  network_name = "${local.prefix}vpc-demo"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.vpc_demo_subnet_l7_ilb}"
      subnet_ip             = "10.1.12.0/24"
      subnet_region         = "us-east1"
      subnet_private_access = false
      subnet_flow_logs      = false
    },
  ]

  secondary_ranges = {
    "${local.vpc_demo_subnet_l7_ilb}" = []
  }
}

resource "google_compute_firewall" "vpc_demo_allow_internal" {
  provider = "google-beta"
  name     = "${local.prefix}vpc-demo-allow-internal"
  network  = "${module.vpc_demo.network_self_link}"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.1.0.0/16"]
}

resource "google_compute_firewall" "vpc_demo_allow_ssh_http_s_icmp" {
  provider = "google-beta"
  name     = "${local.prefix}vpc-demo-allow-ssh-http-s-icmp"
  network  = "${module.vpc_demo.network_self_link}"

  allow {
    protocol = "tcp"
    ports    = [22, 80, 443]
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "vpc_demo_allow_http_ilb_tcp" {
  provider = "google-beta"
  name     = "${local.prefix}vpc-demo-allow-http-ilb-tcp"
  network  = "${module.vpc_demo.network_self_link}"

  allow {
    protocol = "tcp"
  }

  source_ranges = ["10.126.0.0/22"]
}

module "apache" {
  source                    = "../../modules/l7_ilb"
  project_id                = "${var.project_id}"
  prefix                    = "${local.prefix}"
  instance_template_name    = "apache-template"
  region                    = "us-east1"
  machine_type              = "${local.machine_type}"
  image                     = "${local.image}"
  subnetwork_project        = "${var.project_id}"
  subnetwork                = "${module.vpc_demo.subnets_self_links[0]}"
  metadata_startup_script   = "${file("scripts/apache.sh")}"
  instance_group_name       = "apache-instance-group"
  distribution_policy_zones = ["us-east1-b"]
  target_size               = 2
}

module "nginx" {
  source                    = "../../modules/l7_ilb"
  project_id                = "${var.project_id}"
  prefix                    = "${local.prefix}"
  instance_template_name    = "nginx-template"
  region                    = "us-east1"
  machine_type              = "${local.machine_type}"
  image                     = "${local.image}"
  subnetwork_project        = "${var.project_id}"
  subnetwork                = "${module.vpc_demo.subnets_self_links[0]}"
  metadata_startup_script   = "${file("scripts/nginx.sh")}"
  instance_group_name       = "nginx-instance-group"
  distribution_policy_zones = ["us-east1-c"]
  target_size               = 2
}
