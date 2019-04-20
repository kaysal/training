# Create mynetwork network
resource "google_compute_network" "my_network" {
  name                    = "mynetwork"
  auto_create_subnetworks = true
}

# Add a firewall rule to allow HTTP, SSH, and RDP traffic on mynetwork
resource "google_compute_firewall" "mynetwork_allow_http_ssh_rdp" {
  name    = "mynetwork-allow-http-ssh-rdp"
  network = "${google_compute_network.my_network.self_link}"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "3389"]
  }
}

# Add a firewall rule to allow ICMP traffic on mynetwork
resource "google_compute_firewall" "mynetwork_allow_icmp" {
  name    = "mynetwork-allow-icmp"
  network = "${google_compute_network.my_network.self_link}"

  allow {
    protocol = "icmp"
  }
}

# Add the mynet-us-vm instance
resource "google_compute_instance" "mynet_us_vm" {
  name         = "mynet-us-vm"
  zone         = "us-central1-a"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "${google_compute_network.my_network.self_link}"

    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
}

# Add the mynet-eu-vm instance
resource "google_compute_instance" "mynet_eu_vm" {
  name         = "mynet-eu-vm"
  zone         = "europe-west1-d"
  machine_type = "n1-standard-1"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    network = "${google_compute_network.my_network.self_link}"

    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }
}
