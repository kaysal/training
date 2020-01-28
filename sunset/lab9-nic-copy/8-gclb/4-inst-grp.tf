
# unmanaged instance group

resource "google_compute_instance_group" "instance_grp1" {
  name      = "${var.spoke1.prefix}ig1"
  zone      = "${var.spoke1.region}-a"
  instances = [google_compute_instance.gclb_vm1.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}

resource "google_compute_instance_group" "instance_grp2" {
  name      = "${var.spoke1.prefix}ig2"
  zone      = "${var.spoke1.region}-b"
  instances = [google_compute_instance.gclb_vm2.self_link]

  named_port {
    name = "http"
    port = "80"
  }
}
