
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

# cloud1
#---------------------------------------------

# vpc

module "cloud1_vpc" {
  source       = "../../modules/vpc"
  network_name = "${var.cloud1.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = "${var.cloud1.prefix}subnet"
      subnet_ip                = var.cloud1.subnet_cidr
      subnet_region            = var.cloud1.region
      private_ip_google_access = true
    },
  ]

  secondary_ranges = {
    "${var.cloud1.prefix}subnet" = []
  }
}

# routes for restricted API IP range

resource "google_compute_route" "cloud1_private_googleapis" {
  name             = "${var.cloud1.prefix}private-googleapis"
  description      = "Route to default gateway for PGA"
  dest_range       = "199.36.153.4/30"
  network          = module.cloud1_vpc.network.self_link
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

# firewall rules

resource "google_compute_firewall" "cloud1_allow_ssh" {
  name    = "${var.cloud1.prefix}allow-ssh"
  network = module.cloud1_vpc.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloud1_allow_rfc1918" {
  name    = "${var.cloud1.prefix}allow-rfc1918"
  network = module.cloud1_vpc.network.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

resource "google_compute_firewall" "cloud1_dns_egress_proxy" {
  name    = "${var.cloud1.prefix}dns-egress-proxy"
  network = module.cloud1_vpc.network.self_link

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

# cloud2
#---------------------------------------------

# vpc

module "cloud2_vpc" {
  source       = "../../modules/vpc"
  network_name = "${var.cloud2.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = "${var.cloud2.prefix}subnet"
      subnet_ip                = var.cloud2.subnet_cidr
      subnet_region            = var.cloud2.region
      private_ip_google_access = true
    },
  ]

  secondary_ranges = {
    "${var.cloud2.prefix}subnet" = []
  }
}

# firewall rules

resource "google_compute_firewall" "cloud2_allow_ssh" {
  name    = "${var.cloud2.prefix}allow-ssh"
  network = module.cloud2_vpc.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloud2_allow_rfc1918" {
  name    = "${var.cloud2.prefix}allow-rfc1918"
  network = module.cloud2_vpc.network.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}

# cloud3
#---------------------------------------------

# vpc

module "cloud3_vpc" {
  source       = "../../modules/vpc"
  network_name = "${var.cloud3.prefix}vpc"
  routing_mode = "REGIONAL"

  subnets = [
    {
      subnet_name              = "${var.cloud3.prefix}subnet"
      subnet_ip                = var.cloud3.subnet_cidr
      subnet_region            = var.cloud3.region
      private_ip_google_access = true
    },
  ]

  secondary_ranges = {
    "${var.cloud3.prefix}subnet" = []
  }
}

# firewall rules

resource "google_compute_firewall" "cloud3_allow_ssh" {
  name    = "${var.cloud3.prefix}allow-ssh"
  network = module.cloud3_vpc.network.self_link

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "cloud3_allow_rfc1918" {
  name    = "${var.cloud3.prefix}allow-rfc1918"
  network = module.cloud3_vpc.network.self_link

  allow {
    protocol = "all"
  }

  source_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]
}
