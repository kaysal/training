
# nat ip

resource "google_compute_address" "untrust_nat_ip" {
  name   = "untrust-nat-ip"
  region = var.hub.vpc_untrust.eu.region
}

# nat gateway

module "natgw_eu_west1" {
  source         = "../../../modules/natgw-multi-nic"
  project        = var.project_id
  prefix         = ""
  vpc_trust      = local.vpc_trust.self_link
  zone           = "${var.hub.vpc_trust.eu.region}-c"
  trust_ip       = var.hub.vpc_trust.eu.ip.natgw
  trust_ip_dgw   = var.hub.vpc_trust.eu.cidr.dgw
  trust_subnet   = local.subnet.eu.trust.self_link
  untrust_ip     = var.hub.vpc_untrust.eu.ip.natgw
  untrust_subnet = local.subnet.eu.untrust.self_link
  untrust_nat_ip = google_compute_address.untrust_nat_ip.address
}
