
provider "google" {
  project     = "${var.project_name}"
  credentials = "${file("${var.credentials_file_path}")}"
}

# remote state file for aws - containing tunnel 1 and
# tunnel 2 aws vpn addresses needed for the strongswan
# tunnel configuration
#---------------------------------------------

data "terraform_remote_state" "aws_data" {
  backend = "local"

  config {
    path = "../aws-vpn/terraform.tfstate"
  }
}

# Get the static ip address reserved on gcp
# console to be used for the gcp vpn gateway
#--------------------------------------
data "google_compute_address" "strongswan_vpn_gw_ip" {
  name   = "strongswan-vpn-gw-ip"
  region = "europe-west2"
}

# Create VPC
#--------------------------------------
resource "google_compute_network" "vpn_network" {
  name                    = "${var.name}-vpc"
  auto_create_subnetworks = "false"
}

# Create Subnet
#--------------------------------------
resource "google_compute_subnetwork" "vpn_subnet" {
  name          = "${var.name}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = "${google_compute_network.vpn_network.self_link}"
  region        = "europe-west2"
}

# Create the instances
#--------------------------------------
resource "google_compute_instance" "vpn_gateway" {
  name           = "${var.name}-gateway"
  machine_type   = "n1-standard-1"
  zone           = "europe-west2-c"
  tags           = ["vpn-gateway"]
  can_ip_forward = "true"

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-9"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.vpn_subnet.name}"

    access_config {
      nat_ip = "${data.google_compute_address.strongswan_vpn_gw_ip.address}"
    }
  }

  metadata {
    ssh-keys = "user:${file("${var.public_key_path}")}"
  }

  metadata_startup_script = "${file("scripts/strongswan.sh")}"

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

resource "google_compute_instance" "gcp_instance" {
  name         = "gcp-instance"
  machine_type = "n1-standard-1"
  zone         = "europe-west2-c"
  tags         = ["vpn"]

  boot_disk {
    initialize_params {
      image = "projects/debian-cloud/global/images/family/debian-9"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.vpn_subnet.name}"
  }

  metadata {
    ssh-keys = "user:${file("${var.public_key_path}")}"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/compute.readonly"]
  }
}

# Create firewall rules
#--------------------------------------
# allow internal ssh from authorized service account
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.name}-allow-ssh"
  network = "${google_compute_network.vpn_network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${var.name}-allow-internal"
  network = "${google_compute_network.vpn_network.self_link}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  source_ranges = ["10.0.0.0/24"]
}

resource "google_compute_firewall" "allow_ipsec_nat" {
  name    = "${var.name}-allow-ipsec-nat"
  network = "${google_compute_network.vpn_network.self_link}"

  allow {
    protocol = "udp"
    ports    = ["500", "4500"]
  }

  source_ranges = [
    "${data.terraform_remote_state.aws_data.vpn_connection_tunnel1_address}",
    "${data.terraform_remote_state.aws_data.vpn_connection_tunnel2_address}",
  ]

  target_tags = ["vpn-gateway"]
}

resource "google_compute_firewall" "from_onprem" {
  name    = "${var.name}-from-onprem"
  network = "${google_compute_network.vpn_network.self_link}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  target_tags = ["vpn"]
}

# Create GCE route to AWS network
# route to aws tunnel 1 takes precedence
# (lower priority)
#--------------------------------------
resource "google_compute_route" "aws_tunnel1_route" {
  name        = "${var.name}-aws-tunnel1-route"
  dest_range  = "10.0.1.0/24"
  network     = "${google_compute_network.vpn_network.self_link}"
  next_hop_instance = "${google_compute_instance.vpn_gateway.name}"
  next_hop_instance_zone = "europe-west2-c"
  priority    = 100
  tags = ["vpn"]
}

resource "google_compute_route" "aws_tunnel2_route" {
  name        = "${var.name}-aws-tunnel2-route"
  dest_range  = "10.0.1.0/24"
  network     = "${google_compute_network.vpn_network.self_link}"
  next_hop_instance = "${google_compute_instance.vpn_gateway.name}"
  next_hop_instance_zone = "europe-west2-c"
  priority    = 100
  tags = ["vpn"]
}
