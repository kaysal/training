
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

locals {
  onprem = {
    prefix      = "lab1-onprem-"
    region      = "europe-west1"
    subnet_cidr = "172.16.1.0/24"
  }

  cloud = {
    prefix      = "lab1-cloud-"
    region      = "europe-west1"
    subnet_cidr = "10.10.1.0/24"
  }
}

# onprem
#---------------------------------------------

# vpc

module "onprem_vpc" {
  source       = "../../modules/vpc"
  network_name = "${local.onprem.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = "${local.onprem.prefix}subnet"
      subnet_ip                = local.onprem.subnet_cidr
      subnet_region            = local.onprem.region
      private_ip_google_access = false
    },
  ]

  secondary_ranges = {
    "${local.onprem.prefix}subnet" = []
  }
}

# firewall rules

resource "google_compute_firewall" "onprem_allow_ssh" {
  name    = "${local.onprem.prefix}allow-ssh"
  network = module.onprem_vpc.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "onprem_allow_rfc1918" {
  name    = "${local.onprem.prefix}allow-rfc1918"
  network = module.onprem_vpc.network.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "onprem_dns_egress_proxy" {
  name    = "${local.onprem.prefix}dns-egress-proxy"
  network = module.onprem_vpc.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = ["35.199.192.0/19"]
}

# cloud
#---------------------------------------------

# vpc

module "cloud_vpc" {
  source       = "../../modules/vpc"
  network_name = "${local.cloud.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = "${local.cloud.prefix}subnet"
      subnet_ip                = local.cloud.subnet_cidr
      subnet_region            = local.cloud.region
      private_ip_google_access = false
    },
  ]

  secondary_ranges = {
    "${local.cloud.prefix}subnet" = []
  }
}

# firewall rules

resource "google_compute_firewall" "cloud_allow_ssh" {
  name    = "${local.cloud.prefix}allow-ssh"
  network = module.cloud_vpc.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloud_allow_rfc1918" {
  name    = "${local.cloud.prefix}allow-rfc1918"
  network = module.cloud_vpc.network.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "cloud_dns_egress_proxy" {
  name    = "${local.cloud.prefix}dns-egress-proxy"
  network = module.cloud_vpc.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }

  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = ["35.199.192.0/19"]
}
