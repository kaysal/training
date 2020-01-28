
# unmanaged instance group

resource "google_compute_instance_group" "instance_grp_eu" {
  project   = var.project_id_spoke1
  name      = "${var.spoke1.prefix}ig-eu"
  zone      = "${var.spoke1.region_eu}-b"
  instances = [local.spoke1.vm_eu.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "instance_grp_asia" {
  project   = var.project_id_spoke1
  name      = "${var.spoke1.prefix}ig-asia"
  zone      = "${var.spoke1.region_asia}-b"
  instances = [local.spoke1.vm_asia.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "instance_grp_us" {
  project   = var.project_id_spoke1
  name      = "${var.spoke1.prefix}ig-us"
  zone      = "${var.spoke1.region_us}-b"
  instances = [local.spoke1.vm_us.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}
