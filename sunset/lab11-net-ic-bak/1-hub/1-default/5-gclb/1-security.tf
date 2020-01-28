
# default deny 0.0.0.0/0
# and allow us probe only
#-----------------------------------

resource "google_compute_security_policy" "allow_external" {
  name = "allow-external"

  rule {
    action   = "allow"
    priority = "1000"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = [
          local.probe_asia_nat_ip.address,
          local.probe_eu_nat_ip.address,
          local.probe_us_nat_ip.address,
        ]
      }
    }

    description = "allow only us probe"
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }

    description = "default rule"
  }
}
