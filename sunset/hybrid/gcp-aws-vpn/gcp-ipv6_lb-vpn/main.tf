# https://cloud.google.com/compute/docs/load-balancing/http/content-based-example

provider "google" {
  region      = "${var.region}"
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
  zone        = "${var.region_zone}"
}

# remote state file for aws containing tunnel 1 and
# tunnel 2 aws vpn addresses needed for the gcp
# tunnel configuration
#---------------------------------------------
data "terraform_remote_state" "aws_data" {
  backend = "local"
  config {
    path = "../aws-vpn/terraform.tfstate"
  }
}

# Get the static ip address reserved on gcp console
# to be used for the gcp vpn gateway
data "google_compute_address" "vpn_gw_ip" {
  name = "vpn-gw-ip"
}

# Create VPC
#--------------------------------------
resource "google_compute_network" "vpc_demo" {
  name                    = "vpc-demo"
  auto_create_subnetworks = "false"
}

# Create Subnet
#--------------------------------------
resource "google_compute_subnetwork" "subnet_lb" {
  name          = "subnet-lb"
  ip_cidr_range = "172.16.10.0/24"
  network       = "${google_compute_network.vpc_demo.self_link}"
  region        = "${var.region}"
}

# Create Subnet
#--------------------------------------
resource "google_compute_subnetwork" "subnet_bastion" {
  name          = "subnet-bastion"
  ip_cidr_range = "172.16.1.0/24"
  network       = "${google_compute_network.vpc_demo.self_link}"
  region        = "${var.region}"
}

#Create the www instances
#------------------------
resource "google_compute_instance" "www" {
  name         = "tf-www-compute"
  machine_type = "f1-micro"
  tags         = ["http-tag"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-8"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet_lb.name}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    ssh-keys = "kayode:${file("${var.public_key_path}")}"
  }

  metadata_startup_script = "${file("scripts/install-www.sh")}"

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

# Create the www-video instance
#------------------------------
resource "google_compute_instance" "www-video" {
  name         = "tf-www-video-compute"
  machine_type = "f1-micro"
  tags         = ["http-tag"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-8"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet_lb.name}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    ssh-keys = "kayode:${file("${var.public_key_path}")}"
  }

  metadata_startup_script = "${file("scripts/install-video.sh")}"

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

# Create the bastion server in the subnet_bastion subnet
#-------------------------------------------------------
resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "f1-micro"
  tags         = ["bastion-tag"]
  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-8"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.subnet_bastion.name}"

    access_config {
      // Ephemeral IP
    }
  }

  metadata {
    ssh-keys = "kayode:${file("${var.public_key_path}")}"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

# Create instance group for www backends
#---------------------------------------
resource "google_compute_instance_group" "www-resources" {
  name = "tf-www-resources"

  instances = ["${google_compute_instance.www.self_link}"]

  named_port {
    name = "http"
    port = "80"
  }
}

# Create instance group for www-video backends
#---------------------------------------
resource "google_compute_instance_group" "video-resources" {
  name = "tf-video-resources"

  instances = ["${google_compute_instance.www-video.self_link}"]

  named_port {
    name = "http"
    port = "80"
  }
}


resource "google_compute_health_check" "health-check" {
  name = "tf-health-check"

  http_health_check {}
}

resource "google_compute_backend_service" "www-service" {
  name     = "tf-www-service"
  protocol = "HTTP"

  backend {
    group = "${google_compute_instance_group.www-resources.self_link}"
  }

  health_checks = ["${google_compute_health_check.health-check.self_link}"]
}

resource "google_compute_backend_service" "video-service" {
  name     = "tf-video-service"
  protocol = "HTTP"

  backend {
    group = "${google_compute_instance_group.video-resources.self_link}"
  }

  health_checks = ["${google_compute_health_check.health-check.self_link}"]
}

resource "google_compute_url_map" "web-map" {
  name            = "tf-web-map"
  default_service = "${google_compute_backend_service.www-service.self_link}"

  host_rule {
    hosts        = ["*"]
    path_matcher = "tf-allpaths"
  }

  path_matcher {
    name            = "tf-allpaths"
    default_service = "${google_compute_backend_service.www-service.self_link}"

    path_rule {
      paths   = ["/video", "/video/*"]
      service = "${google_compute_backend_service.video-service.self_link}"
    }
  }
}


#--------------------------------------
resource "google_compute_target_http_proxy" "http-lb-proxy" {
  name    = "tf-http-lb-proxy"
  url_map = "${google_compute_url_map.web-map.self_link}"
}

/*resource "google_compute_global_address" "external-address" {
//  name = "tf-external-address"
}*/

resource "google_compute_global_address" "external-address-ipv6" {
  name = "tf-external-address-ipv6"
  ip_version = "IPV6"
}


resource "google_compute_global_forwarding_rule" "default" {
  name       = "tf-http-content-gfr"
  target     = "${google_compute_target_http_proxy.http-lb-proxy.self_link}"
  ip_address = "${google_compute_global_address.external-address-ipv6.address}"
  port_range = "80"
}


# Create firewall rules
#--------------------------------------

# FW rule to allow HTTP proxy access backend instances on http
# FW rule uses target tags applied on www and www-video instances
resource "google_compute_firewall" "default" {
  name    = "tf-www-firewall-allow-internal-only"
  network = "${google_compute_network.vpc_demo.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["http-tag"]
}

# FW rule to allow SSH access from bastion to all vpc instances
# FW rule uses service accounts for rule target
resource "google_compute_firewall" "allow_internal_ssh" {
  name    = "allow-internal-ssh-only"
  network = "${google_compute_network.vpc_demo.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_service_accounts  = ["${var.source_service_accounts}"]
}

# FW rule to allow ICMP access from bastion to all vpc instances
# FW rule uses service accounts for rule target
resource "google_compute_firewall" "allow_internal_icmp" {
  name    = "allow-internal-icmp-only"
  network = "${google_compute_network.vpc_demo.self_link}"

  allow {
    protocol = "icmp"
    //ports    = ["22"]
  }

  source_service_accounts  = ["${var.source_service_accounts}"]
  target_service_accounts  = ["${var.source_service_accounts}"]
}

# FW rule to allow external SSH access into bastion network
resource "google_compute_firewall" "allow_external_ssh" {
  name    = "allow-external-ssh"
  network = "${google_compute_network.vpc_demo.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges  = ["0.0.0.0/0"]
  target_tags   = ["bastion-tag"]
}

/*
resource "google_compute_firewall" "allow_external_http" {
  name    = "allow-external-http"
  network = "${google_compute_network.vpc.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges  = ["0.0.0.0/0"]
}
*/

#VPN CONFIGURATION
#===================================

# Attach a VPN gateway to the VPC.
resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "vpn-gateway"
  network = "${google_compute_network.vpc_demo.self_link}"
  region  = "${var.region}"
}

# Forward IPSec traffic coming into our static IP to our VPN gateway.
resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  region      = "${var.region}"
  ip_protocol = "ESP"
  ip_address  = "${data.google_compute_address.vpn_gw_ip.address}"
  target      = "${google_compute_vpn_gateway.target_gateway.self_link}"
}

# The following two sets of forwarding rules are used as a part of the IPSec
# protocol
resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  region      = "${var.region}"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = "${data.google_compute_address.vpn_gw_ip.address}"
  target      = "${google_compute_vpn_gateway.target_gateway.self_link}"
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  region      = "${var.region}"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = "${data.google_compute_address.vpn_gw_ip.address}"
  target      = "${google_compute_vpn_gateway.target_gateway.self_link}"
}

# Each tunnel is responsible for encrypting and decrypting traffic exiting
# and leaving its associated gateway
# We will create 2 tunnels to aws on same GCP VPN gateway
resource "google_compute_vpn_tunnel" "tunnel1" {
  name               = "aws-tunnel1"
  region             = "${var.region}"
  peer_ip            = "${data.terraform_remote_state.aws_data.vpn_connection_tunnel1_address}"
  ike_version = "1"
  shared_secret      = "${var.preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.target_gateway.self_link}"

  local_traffic_selector  = [
    "${google_compute_subnetwork.subnet_lb.ip_cidr_range}",
    "${google_compute_subnetwork.subnet_bastion.ip_cidr_range}"
  ]
  remote_traffic_selector = [
    "${var.remote_cidr}"
  ]

  depends_on = ["google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
    "google_compute_forwarding_rule.fr_esp",
  ]
}

resource "google_compute_vpn_tunnel" "tunnel2" {
  name               = "aws-tunnel2"
  region             = "${var.region}"
  peer_ip            = "${data.terraform_remote_state.aws_data.vpn_connection_tunnel2_address}"
  ike_version = "1"
  shared_secret      = "${var.preshared_key}"
  target_vpn_gateway = "${google_compute_vpn_gateway.target_gateway.self_link}"

  local_traffic_selector  = [
    "${google_compute_subnetwork.subnet_lb.ip_cidr_range}",
    "${google_compute_subnetwork.subnet_bastion.ip_cidr_range}"
  ]
  remote_traffic_selector = [
    "${var.remote_cidr}"
  ]

  depends_on = ["google_compute_forwarding_rule.fr_udp500",
    "google_compute_forwarding_rule.fr_udp4500",
    "google_compute_forwarding_rule.fr_esp",
  ]
}

# Create GCE route to AWS network via the VPN tunnel1
# Two routes are created - one for each of the vpn tunnels
# to the 2 AWS headends

# route through tunnel 1 takes precedence with lower priority
resource "google_compute_route" "aws_tunnel1_route" {
  name        = "aws-tunnel1-route"
  dest_range  = "10.0.1.0/24"
  network     = "${google_compute_network.vpc_demo.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel1.self_link}"
  priority    = 90
}

resource "google_compute_route" "aws_tunnel2_route" {
  name        = "aws-tunnel2-route"
  dest_range  = "10.0.1.0/24"
  network     = "${google_compute_network.vpc_demo.self_link}"
  next_hop_vpn_tunnel = "${google_compute_vpn_tunnel.tunnel2.self_link}"
  priority    = 100
}
