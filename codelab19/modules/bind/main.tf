# Bastion host
#============================

data "template_file" "bind_init" {
  template = "${file("${path.module}/scripts/bind.sh.tpl")}"

  vars = {
    NAME_SERVER          = "127.0.0.1"
    DOMAIN_NAME          = "training.com"
    DOMAIN_NAME_SEARCH   = "onprem.training.com"
    LOCAL_FORWARDERS     = "169.254.169.254"
    LOCAL_NAME_SERVER_IP = "${var.local_name_server_ip}"
    LOCAL_ZONE           = "onprem.training.com"
    LOCAL_ZONE_FILE      = "/etc/bind/db.googleapis.zone"
    LOCAL_ZONE_INV       = "10.10.10.in-addr.arpa"
    LOCAL_ZONE_INV_FILE  = "/etc/bind/db.onprem.training.com.inv"
    GCP_DNS_RANGE        = "35.199.192.0/19"
    GOOGLEAPIS_ZONE      = "googleapis.zone"
    GOOGLEAPIS_ZONE_FILE = "/etc/bind/db.googleapis.zone"
    REMOTE_ZONE_GCP      = "host.cloudtuple.com"
    REMOTE_NS_GCP        = "10.1.1.3"
  }
}

resource "google_compute_instance" "bind" {
  project                   = "${var.project}"
  name                      = "${var.name}"
  machine_type              = "${var.machine_type}"
  zone                      = "${var.zone}"
  allow_stopping_for_update = true
  can_ip_forward            = true

  boot_disk {
    initialize_params {
      image = "${var.image}"
    }
  }

  network_interface {
    subnetwork_project = "${var.network_project}"
    subnetwork         = "${var.subnetwork}"
    network_ip         = "${var.local_name_server_ip}"
    access_config      = {}
  }

  metadata_startup_script = "${data.template_file.bind_init.rendered}"

  service_account {
    scopes = ["cloud-platform"]
  }
}
