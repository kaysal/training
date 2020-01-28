
# browse
#---------------------------------------

# asia

resource "google_compute_instance_group_manager" "browse_asia" {
  name               = "browse-asia"
  base_instance_name = "browse-asia"
  zone               = "${var.hub.default.asia.region}-b"

  version {
    instance_template = local.templates.browse_asia.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "browse_asia" {
  name   = "browse-asia"
  zone   = "${var.hub.default.asia.region}-b"
  target = google_compute_instance_group_manager.browse_asia.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# eu

resource "google_compute_instance_group_manager" "browse_eu" {
  name               = "browse-eu"
  base_instance_name = "browse-eu"
  zone               = "${var.hub.default.eu.region}-b"

  version {
    instance_template = local.templates.browse_eu.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "browse_eu" {
  name   = "browse-eu"
  zone   = "${var.hub.default.eu.region}-b"
  target = google_compute_instance_group_manager.browse_eu.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# us
resource "google_compute_instance_group_manager" "browse_us" {
  name               = "browse-us"
  base_instance_name = "browse-us"
  zone               = "${var.hub.default.us.region}-c"

  version {
    instance_template = local.templates.browse_us.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "browse_us" {
  name   = "browse-us"
  zone   = "${var.hub.default.us.region}-c"
  target = google_compute_instance_group_manager.browse_us.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}


# cart
#---------------------------------------

# asia

resource "google_compute_instance_group_manager" "cart_asia" {
  name               = "cart-asia"
  base_instance_name = "cart-asia"
  zone               = "${var.hub.default.asia.region}-b"

  version {
    instance_template = local.templates.cart_asia.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "cart_asia" {
  name   = "cart-asia"
  zone   = "${var.hub.default.asia.region}-b"
  target = google_compute_instance_group_manager.cart_asia.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# eu

resource "google_compute_instance_group_manager" "cart_eu" {
  name               = "cart-eu"
  base_instance_name = "cart-eu"
  zone               = "${var.hub.default.eu.region}-b"

  version {
    instance_template = local.templates.cart_eu.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "cart_eu" {
  name   = "cart-eu"
  zone   = "${var.hub.default.eu.region}-b"
  target = google_compute_instance_group_manager.cart_eu.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# us
resource "google_compute_instance_group_manager" "cart_us" {
  name               = "cart-us"
  base_instance_name = "cart-us"
  zone               = "${var.hub.default.us.region}-c"

  version {
    instance_template = local.templates.cart_us.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "cart_us" {
  name   = "cart-us"
  zone   = "${var.hub.default.us.region}-c"
  target = google_compute_instance_group_manager.cart_us.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}


# checkout
#---------------------------------------

# asia

resource "google_compute_instance_group_manager" "checkout_asia" {
  name               = "checkout-asia"
  base_instance_name = "checkout-asia"
  zone               = "${var.hub.default.asia.region}-b"

  version {
    instance_template = local.templates.checkout_asia.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "checkout_asia" {
  name   = "checkout-asia"
  zone   = "${var.hub.default.asia.region}-b"
  target = google_compute_instance_group_manager.checkout_asia.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# eu

resource "google_compute_instance_group_manager" "checkout_eu" {
  name               = "checkout-eu"
  base_instance_name = "checkout-eu"
  zone               = "${var.hub.default.eu.region}-b"

  version {
    instance_template = local.templates.checkout_eu.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "checkout_eu" {
  name   = "checkout-eu"
  zone   = "${var.hub.default.eu.region}-b"
  target = google_compute_instance_group_manager.checkout_eu.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# us

resource "google_compute_instance_group_manager" "checkout_us" {
  name               = "checkout-us"
  base_instance_name = "checkout-us"
  zone               = "${var.hub.default.us.region}-c"

  version {
    instance_template = local.templates.checkout_us.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "checkout_us" {
  name   = "checkout-us"
  zone   = "${var.hub.default.us.region}-c"
  target = google_compute_instance_group_manager.checkout_us.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

/*
# feeds
#---------------------------------------

# asia

resource "google_compute_instance_group_manager" "feeds_asia" {
  name               = "feeds-asia"
  base_instance_name = "feeds-asia"
  zone               = "${var.hub.default.asia.region}-b"

  version {
    instance_template = local.templates.feeds_asia.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "feeds_asia" {
  name   = "feeds-asia"
  zone   = "${var.hub.default.asia.region}-b"
  target = google_compute_instance_group_manager.feeds_asia.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# eu

resource "google_compute_instance_group_manager" "feeds_eu" {
  name               = "feeds-eu"
  base_instance_name = "feeds-eu"
  zone               = "${var.hub.default.eu.region}-b"

  version {
    instance_template = local.templates.feeds_eu.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "feeds_eu" {
  name   = "feeds-eu"
  zone   = "${var.hub.default.eu.region}-b"
  target = google_compute_instance_group_manager.feeds_eu.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}

# us

resource "google_compute_instance_group_manager" "feeds_us" {
  name               = "feeds-us"
  base_instance_name = "feeds-us"
  zone               = "${var.hub.default.us.region}-c"

  version {
    instance_template = local.templates.feeds_us.self_link
  }

  named_port {
    name = "http"
    port = "80"
  }

  auto_healing_policies {
    health_check      = local.default_hc.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_autoscaler" "feeds_us" {
  name   = "feeds-us"
  zone   = "${var.hub.default.us.region}-c"
  target = google_compute_instance_group_manager.feeds_us.self_link

  autoscaling_policy {
    min_replicas    = 1
    max_replicas    = 10
    cooldown_period = 60

    cpu_utilization {
      target = "0.7"
    }
  }
}
*/
