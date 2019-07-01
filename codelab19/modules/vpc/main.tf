# vpc configuration

resource "google_compute_network" "network" {
  name                    = var.network_name
  auto_create_subnetworks = "false"
  routing_mode            = var.routing_mode
  project                 = var.project_id
}

# subnet

resource "google_compute_subnetwork" "subnetwork" {
  count = length(var.subnets)

  name                     = var.subnets[count.index]["subnet_name"]
  ip_cidr_range            = var.subnets[count.index]["subnet_ip"]
  region                   = var.subnets[count.index]["subnet_region"]
  private_ip_google_access = lookup(var.subnets[count.index], "subnet_private_access", "false")
  enable_flow_logs         = lookup(var.subnets[count.index], "subnet_flow_logs", "false")
  network                  = google_compute_network.network.name
  project                  = var.project_id

  dynamic "secondary_ip_range" {
    for_each = var.secondary_ranges[var.subnets[count.index]["subnet_name"]]
    content {
      ip_cidr_range = lookup(secondary_ip_range.value, "ip_cidr_range", null)
      range_name    = lookup(secondary_ip_range.value, "range_name", null)
    }
  }
}

data "google_compute_subnetwork" "created_subnets" {
  count = length(var.subnets)

  name    = element(google_compute_subnetwork.subnetwork.*.name, count.index)
  region  = element(google_compute_subnetwork.subnetwork.*.region, count.index)
  project = var.project_id
}
