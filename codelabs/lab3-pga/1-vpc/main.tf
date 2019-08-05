
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# onprem
#---------------------------------------------

# vpc

module "onprem_vpc" {
  source       = "../../modules/vpc"
  network_name = "${var.onprem.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = "${var.onprem.prefix}subnet"
      subnet_ip                = var.onprem.subnet_cidr
      subnet_region            = var.onprem.region
      private_ip_google_access = false
    },
  ]

  secondary_ranges = {
    "${var.onprem.prefix}subnet" = []
  }
}

# firewall rules

resource "google_compute_firewall" "onprem_allow_ssh" {
  name    = "${var.onprem.prefix}allow-ssh"
  network = module.onprem_vpc.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "onprem_allow_rfc1918" {
  name    = "${var.onprem.prefix}allow-rfc1918"
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
  name    = "${var.onprem.prefix}dns-egress-proxy"
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
  network_name = "${var.cloud.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = "${var.cloud.prefix}subnet"
      subnet_ip                = var.cloud.subnet_cidr
      subnet_region            = var.cloud.region
      private_ip_google_access = true
    },
  ]

  secondary_ranges = {
    "${var.cloud.prefix}subnet" = []
  }
}

# firewall rules

resource "google_compute_firewall" "cloud_allow_ssh" {
  name    = "${var.cloud.prefix}allow-ssh"
  network = module.cloud_vpc.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloud_allow_rfc1918" {
  name    = "${var.cloud.prefix}allow-rfc1918"
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
  name    = "${var.cloud.prefix}dns-egress-proxy"
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
