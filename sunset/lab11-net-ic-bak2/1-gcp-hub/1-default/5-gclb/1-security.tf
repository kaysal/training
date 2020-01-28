
# default deny 0.0.0.0/0
# and allow us probe only
#-----------------------------------

# probers from EMEA
#104.132.162.95
#104.134.21.8

resource "google_compute_security_policy" "allowed_clients" {
  name = "allowed-clients"

  rule {
    action   = "allow"
    priority = "1000"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = [
          local.aws.ohio_eip.public_ip,
          local.aws.tokyo_eip.public_ip,
          local.aws.singapore_eip.public_ip,
          local.aws.london_eip.public_ip,
        ]
      }
    }

    description = "allowed clients"
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
