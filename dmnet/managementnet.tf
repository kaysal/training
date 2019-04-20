# Create managementnet network
resource "google_compute_network" "management_net" {
  name                    = "managementnet"
  auto_create_subnetworks = false
}

# Create managementsubnet-us subnetwork
resource "google_compute_subnetwork" "management_subnet_us" {
  name          = "managementsubnet-us"
  region        = "us-central1"
  network       = "${google_compute_network.management_net.self_link}"
  ip_cidr_range = "10.130.0.0/20"
}

# Add a firewall rule to allow HTTP, SSH, and RDP traffic on managementnet
resource "google_compute_firewall" "managementnet_allow_http_ssh_rdp" {
  name    = "managementnet-allow-http-ssh-rdp"
  network = "${google_compute_network.management_net.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
  }
}

# Add a firewall rule to allow ICMP traffic on managementnet
resource "google_compute_firewall" "management_net_allow_icmp" {
  name    = "managementnet-allow-icmp"
  network = "${google_compute_network.management_net.self_link}"

  allow {
    protocol = "icmp"
  }
}

# Add the managementnet-us-vm instance
resource "google_compute_instance" "managementnet_us_vm" {
  name         = "managementnet-us-vm"
  zone         = "us-central1-a"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.management_subnet_us.self_link}"

    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
}
