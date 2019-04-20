# Create privatenet network
resource "google_compute_network" "private_net" {
  name                    = "privatenet"
  auto_create_subnetworks = false
}

# Create privatesubnet-us subnetwork
resource "google_compute_subnetwork" "privatesubnet_us" {
  name          = "privatesubnet-us"
  region        = "us-central1"
  network       = "${google_compute_network.private_net.self_link}"
  ip_cidr_range = "172.16.0.0/24"
}

# Add a firewall rule to allow HTTP, SSH, and RDP traffic on privatenet
resource "google_compute_firewall" "privatenet_allow_http_ssh_rdp" {
  name    = "privatenet-allow-http-ssh-rdp"
  network = "${google_compute_network.private_net.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
  }
}

# Add a firewall rule to allow ICMP traffic on privatenet
resource "google_compute_firewall" "privatenet_allow_icmp" {
  name    = "privatenet-allow-icmp"
  network = "${google_compute_network.private_net.self_link}"

  allow {
    protocol = "icmp"
  }
}

# Add the privatenet-us-vm instance
resource "google_compute_instance" "privatenet_us_vm" {
  name         = "privatenet-us-vm"
  zone         = "us-central1-a"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.privatesubnet_us.self_link}"

    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
}
